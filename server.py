import json
from flask import Flask
from flask import request
import operator

app = Flask(__name__)

@app.route('/')
def index():
    return "eGl3ZWk="

@app.route('/api/get_function',methods = ['POST'])
def get_function():
    ops = { '+': operator.add, '-': operator.sub ,'*':operator.mul}
    datadict = request.get_json()
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
        location = temp.index(',')
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
    if(not nostring and not allplus):
        return jsonify({'error':'cannot do the function operation on string type'})
    elif allstring and allplus:
        for i in range(0,number):
            result = result + valuedict['object%d'%(i)][1]
            return jsonify({'type':'str','value':result})
    else:
        operator1 = operatorlist[0]
        result = ops[operator1](float(valuedict['object0'][1]),float(valuedict['object1'][1]))
        for i in range(2,number):
            tempope = operatorlist[i-1]
            result = ops[tempope](float(result),float(valuedict['object%d'%(i)][1]))
        if(not existfloat):
            result = int(result)
            return jsonify({'type':'int','value':result})
        result  =str(result)
    return jsonify({'type':'float','value':result})


if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0',port=5000)

