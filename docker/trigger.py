from subprocess import check_output
from flask import Flask, request, jsonify
import json
import os

app = Flask(__name__)
message_success = "Success"
message_failed = "Failed"

def run_ci_script(script_path):
    try:
        stdout = check_output([script_path]).decode('utf-8')
        data_str = json.loads(stdout)
        web_url = data_str.get('web_url', 'Unknown')
        return message_success + "\nPipeline url: " + web_url
    except Exception as e:
        return message_failed + f"\nError: {str(e)}"

def make_response(route_function):
    return {
        "response_type": "in_channel",
        "text": route_function()
    }

@app.route('/green-ci-destroy', methods=['GET'])
def green_ci_destroy_route():
    return make_response(lambda: run_ci_script('./trigger_scripts/green_ci_destroy.sh'))

@app.route('/green-ci-deploy', methods=['GET'])
def green_ci_deploy_route():
    return make_response(lambda: run_ci_script('./trigger_scripts/green_ci_deploy.sh'))

@app.route('/blue-ci-destroy', methods=['GET'])
def blue_ci_destroy_route():
    return make_response(lambda: run_ci_script('./trigger_scripts/blue_ci_destroy.sh'))

@app.route('/blue-ci-deploy', methods=['GET'])
def blue_ci_deploy_route():
    return make_response(lambda: run_ci_script('./trigger_scripts/blue_ci_deploy.sh'))

@app.route('/blue-workloads-deploy', methods=['GET'])
def blue_workloads_deploy_route():
    return make_response(lambda: run_ci_script('./trigger_scripts/blue_workloads_deploy.sh'))

@app.route('/green-workloads-deploy', methods=['GET'])
def green_workloads_deploy_route():
    return make_response(lambda: run_ci_script('./trigger_scripts/green_workloads_deploy.sh'))

@app.route('/')
def index():
    return "If you see this page, the Slack Slash Command server is successfully installed and working."

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=2045, debug=True)
