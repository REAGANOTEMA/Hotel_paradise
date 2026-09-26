from fastapi import FastAPI
from pydantic import BaseModel

app=FastAPI(title='Hotel Paradise Integration Service',version='1.0')
class PaymentIntent(BaseModel):
    amount: float
    currency: str='UGX'
    reference: str
    callback_url: str|None=None

@app.get('/health')
def health(): return {'ok':True,'service':'integration','hotel':'Hotel Paradise on the Nile'}

@app.post('/payment/intents')
def payment_intent(p:PaymentIntent):
    # Adapter boundary only: connect a licensed/approved gateway here.
    return {'ok':True,'status':'adapter_ready','reference':p.reference,'amount':p.amount,'currency':p.currency}

@app.post('/efris/invoice')
def efris_invoice(payload:dict):
    # Adapter boundary for official URA EFRIS integration. Credentials and API rules belong in environment variables.
    return {'ok':True,'status':'adapter_ready','message':'Connect official EFRIS API credentials and required fiscal workflow.'}
