from fastapi import FastAPI
from pydantic import BaseModel

app=FastAPI(title='Hotel Paradise on the Nile Analytics')

class Event(BaseModel):
    hotel_id:int
    event_type:str
    payload:dict={}

@app.get('/health')
def health():
    return {'status':'ok','hotel':'Hotel Paradise on the Nile'}

@app.post('/events')
def events(event:Event):
    return {'accepted':True,'event_type':event.event_type}
