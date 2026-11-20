# Laravel implementation structure

app/
  Domain/
    Reservations/
    Rooms/
    Guests/
    Folios/
    POS/
    Inventory/
    Finance/
    EFRIS/
    Reception/
    Reports/
  Http/Controllers/Api/V1/
  Policies/
  Jobs/
  Notifications/

Use service classes for business operations and policies for authorization.
Use database transactions around booking/payment/folio operations.
Use queues for notifications and EFRIS retry jobs.
Never put provider secrets in frontend code.
