from flask import Flask, render_template
from flask import request
import os
import subprocess

global tracked_words
tracked_words = {}
global tracked_string
tracked_string = ",".join(str(x) for x in tracked_words.keys())

app = Flask(__name__)

def to_remove(new, old):
    lst3 = [value for value in old if value not in new and (value != '')]
    return lst3


def to_add(new,old):
    return [value for value in new if value not in old and (value != '')]


@app.route('/', methods=['GET', 'POST'])
def index():
    global tracked_words
    global tracked_string
    if request.method == "POST":
        opt = request.form.get('start')
        if opt is not None:
            term = request.form['start']
            if term not in tracked_words.keys():
                output = subprocess.check_output("./run-twitter-producer.sh %s" % (str(term)), shell=True)
                print("output: " + str(output.decode("utf-8")))
                tracked_words[term] = str(output.decode("utf-8")).replace('/n','')
                tracked_string = ",".join(str(x) for x in tracked_words.keys() if (x != ''))
        opt = request.form.get('stop')
        print(request.form)
        if opt is not None:
            term = request.form['stop']
            if term in tracked_words.keys():
                subprocess.check_call("./cancel-twitter-producer.sh %s" % (str(tracked_words[term])))
                tracked_words.pop(term)
                tracked_string = ",".join(str(x) for x in tracked_words.keys() if (x != ''))
    return render_template('index.html', tracked_string=tracked_string, DOCKER_MACHINE_IP=os.environ.get('DOCKER_MACHINE_IP'))
