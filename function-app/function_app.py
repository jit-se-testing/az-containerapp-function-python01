import azure.functions as func
import logging
import json
import os
import base64

app = func.FunctionApp()

# Example vulnerable patterns for demonstration (not actually exploitable in this basic setup)

@app.function_name(name="vulnerableFunction")
@app.route(route="{*route}")
def vulnerable_function(req: func.HttpRequest, route: str) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    # Vulnerability Pattern 1: Potential for NoSQL Injection if data is used directly in DB queries without sanitization
    # Example: req.params.get('user_id') might be crafted if used in a CosmosDB key condition
    user_id = req.params.get('user_id', 'defaultUser')

    # Vulnerability Pattern 2: Potential Information Leakage through verbose logging/errors
    # In a real scenario, avoid logging excessive data, especially sensitive info.
    logging.info(f"Processing request for user: {user_id}")

    # Vulnerability Pattern 3: Using environment variables - Ensure they are managed securely
    # Example: If API_KEY was sensitive and logged or exposed elsewhere.
    api_key = os.environ.get('API_KEY', 'dummy_key_not_set') # Example only
    logging.info(f"Using API Key (example): {api_key[:4]}...") # Avoid logging full key

    # Vulnerability Pattern 4: Hardcoded sensitive string (example)
    # BAD: Never hardcode secrets. Use Key Vault, App Configuration, or Environment Variables.
    SECRET_VALUE = "hardcoded_secret_example"
    logging.info(f"Using hardcoded value (example): {SECRET_VALUE[:4]}...")

    # Vulnerability Pattern 5: Unvalidated input used in logic
    # Example: action parameter directly used without checking allowed values
    action = req.params.get('action', 'view')
    if action == 'delete':
        # In real code, this might trigger a delete operation without proper authz checks
        logging.info("Simulating delete action (vulnerable pattern)")

    # Vulnerability Pattern 6: Handling encoded data without proper checks
    # Example: Assuming data is always valid base64
    try:
        body = req.get_body()
        if body:
            decoded = base64.b64decode(body).decode('utf-8')
            logging.info(f"Decoded data: {decoded[:50]}...")
            # If decoded data was, e.g., XML/JSON parsed insecurely, it could be a vul
    except Exception as e:
        # Vulnerability Pattern 2 again: Error message could leak info
        logging.error(f"Failed to decode body: {str(e)}")

    response_body = {
        "message": f"Processed action '{action}' for user '{user_id}'.",
        "input": {
            "method": req.method,
            "url": req.url,
            "params": dict(req.params),
            "headers": dict(req.headers)
        }
    }

    # Vulnerability Pattern 7: Missing Security Headers in response
    response = func.HttpResponse(
        json.dumps(response_body),
        status_code=200,
        headers={
            # Example: Missing Content-Security-Policy, Strict-Transport-Security etc.
            "Content-Type": "application/json"
        }
    )

    return response 