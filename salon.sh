#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"


LIST_SERVICES() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id") 
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    LIST_SERVICES "I could not find that service. What would you like today?"
  else
    HAS_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    if [[ -z $HAS_SERVICE ]]
    then 
      LIST_SERVICES "I could not find that service. What would you like today?"
    else
      CUSTOMER_INQUIRY
    fi
  fi
}

CUSTOMER_INQUIRY() {
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_EXISTS=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_EXISTS ]]
  then
    echo -e "\nA new customer! What is your name?"
    read CUSTOMER_NAME

    INSERT_VALUE=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

    CREATE_APPOINTMENT
  else 
    CREATE_APPOINTMENT
  fi
  
}

CREATE_APPOINTMENT() {
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  CUST_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  FORMATTED_SERVICE=$(echo $SERVICE | sed 's/\s//g' -E)
  FORMATTED_CUST_NAME=$(echo $CUST_NAME | sed 's/\s//g' -E)
  echo -e "\nWhat time would you like your $FORMATTED_SERVICE be, $FORMATTED_CUST_NAME?"
  read SERVICE_TIME

  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUST_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $FORMATTED_SERVICE at $SERVICE_TIME, $FORMATTED_CUST_NAME."
}

LIST_SERVICES
