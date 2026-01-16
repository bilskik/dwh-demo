# dwh-demo

### info:
Python 3.11.11

Pomocna jest wtyczka do postgresa w vscode (o nazwie postgreSQL)

Przy wdrazaniu dbt na postgresa  
```bash
pip install dbt-postgres  
```

Uruchomienie dbt:  
```bash  
dbt deps
dbt run --profiles-dir .
```

### dane:

https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

Opis danych:
Tabela customer, zawiera:
- customer_id - klucz do orders 
- customer_unique_id - unikalny klucz (PK) 
- customer_zip_code_prefix - piec pierwszych cyfr zip_code'u customera (łączy się z geolocation_zip_code) 
- customer_city - nazwa miasta customera 
- customer_state - stan 

Tabela geolocation, zawiera, geolokacja miejsca: 
- geolocation_zip_code - zip code
- geolocation_lat - szerokosc geog.
- geolocation_lng - dlugosc geog.
- geolocation_city - miasto
- geolocation_state - kod stanu

orders:
- order_id - unikalne id zamowienia 
- customer_id - klucz do customera ktory wykonal zamowienie "Each order has a unique customer_id" czyli ten sam customer jako osoba w realnym swiecie jest przedstawiony tutaj jako dwoch customerow
- order_status - delivered, shipped, etc
- order_purchase_timestamp - czas zakupu zamowienia (timestamp)
- order_approved_at - approve platnosci (timestamp)
- order_delivered_carrier_date - czas przekazania zamowienia do partnera logistycznego
- order_delivered_customer_date - order delivery date do clienta
- order_estimated_delivery_date - spodziewany czas dostarczenia zamowienia do klienta (ta informacja jest wyswietlona klientowi)

order-items: tabela zawierajaca informacje o sprzedanym produkcie (powiazanie ze sprzedajacym i z zamowieniem):
- order_id - FK do orderu
- order_item_id - numer porzadkowy sprzedanej rzeczy (w momencie gdy dwie rzeczy sa sprzedawane przez jednego sellera w jednym zamowieniu)
- product_id - FK dla produktu
- seller_id - FK do sprzedajacego
- shipping_limit_date - max. data dla sprzedajacego kiedy musi dostarczyc swoja paczke do centrum logistycznego
- price - cena produktu
- freight_value - cena przewozu produktu (gdy ilosc_produktow dostarczana jednoczensie > 1 to wtedy cena jest splitowana przez ilosc produktow)

order_payments - platnosci
- order_id - FK do orderu
- payment_sequential - klient moze zaplacic za zamowienie wiecej niz jedna metoda platnosci. Wtedy generujemy sekwencje (1,2 itp)
- payment_type - typ platnosci (metoda)
- payment_installments - ilosc rat
- payment_value - wartosc transakcji

order_reviews - recenzja klienta (po dostaniu produktu/ lub gdy wygasnie spodziewana data dostarczenia)
- review_id - PK
- order_id - FK do orderu
- review_score - ocena (od 1 do 5)
- review_comment_title - tytul komenatarza, po portugalsku (wiekszos null) 
- review_comment_message - komenatrz, po portugalsku (wiekszos null) 
- review_creation_date - moment kiedy ankieta zostala wyslana do klienta 
- review_answer_timestamp - moment odpowiedzenia na ankiete przez klienta

products - opis produktu
- product_id - PK 
- product_category_name - kategoria produktu po Portugalsku 
- product_name_lenght - dlugosc nazwy produktu
- product_description_lenght - dlugosc deskrypcji produktu
- product_photos_qty - liczba opublikowanych foteczek produktu
- product_weight_g - waga produktu (w gramach)
- product_length_cm - dlugosc produktu (cm)
- product_height_cm - wysokosc
- product_width_cm - szerokosc

sellers - sprzedajacy
- seller_id - PK 
- seller_zip_code_prefix - piec pierwszych cyfr zip_code'u sellera (łączy się z geolocation_zip_code)
- seller_city - miasto sprzedajacego
- seller_state - stan sprzedajacego

product_category_name_translation - transalacja kategorii produktow z portugalskiego na angielski
-  product_category_name  - portugalska wersja kategorii produktu
-  product_category_name_english - angielska wersja kategorii produktu
