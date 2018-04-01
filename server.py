#10.30.15.121
#169.232.117.127
import json
from flask import Flask,request,jsonify
import operator
import sys


app = Flask(__name__)

@app.route('/')
def index():
    return "eGl3ZWk="

@app.route('/api/function_result')
def function_result():
    datastring = request.args.get('param')
    datadict = {}
    datalist = datastring.split()
    number = int(datalist[1])
    datadict['number'] = number
    operatorString = datalist[2]
    for i in range (0,number-1):
        datadict['operator%d'%(i)] = operatorString[i]
    for x in range (0,number):
        datadict['object%d'%(x)] = datastring[3+x]
    return get_function(json.dumps(datadict))


def get_function(data):
    ops = {'+': operator.add, '-': operator.sub ,'*':operator.mul}
    datadict = json.loads(data)
    number = datadict['number']
    number= int(number)
    valuedict= {}
    operatorlist = []
    allplus = True
    allstring = True
    nostring = True
    existfloat = False
    result = ''
    for x in range(0,number):
        temp = datadict['object%d'%(x)]
        location = temp.index(':')
        typex = temp[:location]
        valuex = temp[location+1:]
        valuedict['object%d'%(x)] = (typex,valuex)
        if(typex != 'str'):
            allstring = False
        else:
            nostring = False
        if(typex == 'float'):
            existfloat = True
    for y in range(0,number-1):
        operatorlist.append(datadict["operator%d"%(y)])
        if(datadict["operator%d"%(y)] != '+'):
            allplus = False
    if not nostring and not allstring:
        return 'error: cannot do operation between string and int/float'
    elif allstring and not allplus:
        return 'error: cannot do the operation on string'
    elif allstring and allplus:
        for i in range(0,number):
            result = result + valuedict['object%s'%(i)][1]
        return 'str:%s'%(result)
    else:
        operator1 = operatorlist[0]
        result = ops[operator1](float(valuedict['object0'][1]),float(valuedict['object1'][1]))
        for i in range(2,number):
            tempope = operatorlist[i-1]
            result = ops[tempope](float(result),float(valuedict['object%d'%(i)][1]))
        if(not existfloat):
            result = int(result)
            return 'int:%d'%(result)
        result  =str(result)
    return 'float:%s'%(result)

if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0',port=5000)

