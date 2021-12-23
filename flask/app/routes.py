from flask import Flask, render_template
from flask import request
import os
import requests
import logging
import json


global tracked_words
tracked_words = {}
global tracked_string
tracked_string = ",".join(str(x) for x in tracked_words.keys())

app = Flask(__name__)
logging.basicConfig(level=logging.DEBUG)


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
        app.logger.info('POST METHOD: CUSTOM LOG')
        opt = request.form.get('start')
        if opt is not None:
            term = request.form['start']
            if term not in tracked_words.keys():
                jars = requests.get('http://jobmanager:8081/jars')
                json_jars = json.loads(jars.content.decode("utf-8"))
                for jar in json_jars['files']:
                    if jar['name'] == 'kafka-producer-twitter.jar':
                        producer_jar_id = jar['id']
                    if jar['name'] == 'sentiment-analysis.jar':
                        sentiment_jar_id = jar['id']
                producer_output = requests.post(f'http://jobmanager:8081/jars/{producer_jar_id}/run',
                                        data=json.dumps({"programArgs": f"--searchTerms {term}"}),
                                        headers={'content-type': 'application/json'})
                sentiment_output = requests.post(f'http://jobmanager:8081/jars/{sentiment_jar_id}/run',
                                                                           data=json.dumps({"programArgs": f"--searchTerms {term}"}),
                                                                           headers={'content-type': 'application/json'})
                tracked_words[term] =  {
                                        "producer_job_id": eval(producer_output.content.decode("utf-8"))['jobid'],
                                        "sentiment_job_id": eval(sentiment_output.content.decode("utf-8"))['jobid']
                                        }
                tracked_string = ",".join(str(x) for x in tracked_words.keys() if (x != ''))
        opt = request.form.get('stop')
        print(request.form)
        if opt is not None:
            term = request.form['stop']
            if term in tracked_words.keys():
                requests.patch(f'http://jobmanager:8081/jobs/{tracked_words[term]["producer_job_id"]}')
                requests.patch(f'http://jobmanager:8081/jobs/{tracked_words[term]["sentiment_job_id"]}')
                tracked_words.pop(term)
                tracked_string = ",".join(str(x) for x in tracked_words.keys() if (x != ''))
    return render_template('index.html', tracked_string=tracked_string)

if __name__ == '__main__':
    app.run(host='0.0.0.0')