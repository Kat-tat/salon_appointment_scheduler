#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICE_MENU(){
  #get available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  #list of services
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then 
    SERVICE_MENU
  else 
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
    if [[ -z '$SERVICE_NAME'  ]]
    then
      SERVICE_MENU
    else
      echo "What's your phone number?"
      read CUSTOMER_PHONE
      #phone number already exists
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      #new phone number
      if [[ -z $CUSTOMER_NAME ]]
      then
        #get customer name
        echo "What's your name?"
        read CUSTOMER_NAME
        #add to database
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")  
      fi
      #get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      #get time
      echo "What time would you like?"
      read SERVICE_TIME
      #put all values into appointments table
      INSERT_SERVICE_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      #get service name
      #message
      echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi

    
  fi
  exit 0
}

SERVICE_MENU

#return to list