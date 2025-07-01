import azure.functions as func
import logging

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    name = req.params.get('name', 'world')
    return func.HttpResponse(f"Hello, {name}! This is the vulnerableFunction.") 