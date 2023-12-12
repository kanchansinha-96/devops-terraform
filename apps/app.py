app.py
from flask import Flask, jsonify

app = Flask(_name_)
request_count = 0

@app.route('/count', methods=['GET'])
def get_count():
    global request_count
    request_count += 1
    return jsonify({'count': request_count})

if _name_ == '_main_':
     app.run(host='0.0.0.0', port=5000)
