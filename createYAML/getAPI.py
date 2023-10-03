import requests
import json
import yaml
from collections import OrderedDict

def fetch_swagger_json(url):
    response = requests.get(url)
    headers = {"authorization": "Basic ZGV2OjRSNWk3UXd3dzkzMTI="}
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()

def read_responses_json(file_path):
    with open(file_path, 'r') as file:
        return json.load(file)

def process_swagger_json(swagger_json, responses_json):
    for response in responses_json:
        path = response['path']
        method = response['method']
        operation_id = path.replace('/', '') + method.capitalize()

        # Create operation object
        operation_obj = {
            'operationId': operation_id,
            'responses': {
                response['response']: {
                    'description': 'Successful Operation',
                    'content': {
                        'application/json': {
                            'schema': {
                                '$ref': f'#/components/schemas/{response["name"]}'
                            }
                        }
                    }
                }
            }
        }

        # Identify header parameters and update the securitySchemes
        for param in swagger_json['paths'][path][method].get('parameters', []):
            if param['in'] == 'header':
                param_name = param['name']
                swagger_json['components']['securitySchemes'] = swagger_json.get('components', {}).get('securitySchemes', {})
                swagger_json['components']['securitySchemes'][param_name] = {
                    'type': 'apiKey',
                    'in': 'header',
                    'name': param_name
                }

        # Update operation object
        swagger_json['paths'][path][method].update(operation_obj)

        # Create component schema
        response_obj = response['responseOBJ']['data']
        if 'records' in response_obj:
            component_name = f'{response["name"]}Record'
            swagger_json['components']['schemas'][component_name] = {
                'type': 'object',
                'properties': {
                    'records': {
                        'type': 'array',
                        'items': {
                            'type': 'object',
                            'properties': response_obj['records'][0]  # Assuming all records have the same structure
                        }
                    }
                }
            }
        else:
            swagger_json['components']['schemas'][response["name"]] = {
                'type': 'object',
                'properties': response_obj
            }

    # Apply global security
    swagger_json['security'] = [{name: []} for name in swagger_json.get('components', {}).get('securitySchemes', {})]

    return swagger_json

def convert_json_to_yaml(json_data):
    return yaml.dump(json_data, default_flow_style=False, sort_keys=False)

def main():
    swagger_url = "https://api.mtillholdings.com/swagger/v3/swagger.json"
    responses_file_path = "responses.json"  # Path to your responses json file

    swagger_json = fetch_swagger_json(swagger_url)
    responses_json = read_responses_json(responses_file_path)

    updated_swagger_json = process_swagger_json(swagger_json, responses_json)
    swagger_yaml = convert_json_to_yaml(updated_swagger_json)

    with open('swagger.yaml', 'w') as file:
        file.write(swagger_yaml)

if __name__ == "__main__":
    main()
