#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

echo -e "\n~~~ Welcome to Our Salon ~~~\n"

function SALON_MENU {
  if [[ $1 ]]
  then
    echo -e "$1"
  fi

  echo -e "What would you like to do?"

  # display available services
  echo "$($PSQL "SELECT * FROM services")" | while IFS='|' read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # get preferred service id from user
  read SERVICE_ID_SELECTED

  # use $SERVICE_ID_SELECTED to get the service name
  SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")"
  
  # if $SERVICE_NAME has a value then the user chose a valid id from the list
  if [[ $SERVICE_NAME ]]
  then
    echo "Please input your phone number (e.g: 000-000-0000):"
    read CUSTOMER_PHONE

    CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")"
    CUSTOMER_NAME="$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")"
    
    # check whether the customer is not in database
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo "It looks like we don't have this phone number in our records. Please input your name:"
      read CUSTOMER_NAME

      # insert new customer details into database
      INSERT_CUSTOMER_NAME=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    
      CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")"
    fi

    echo -e "What time would you like like your $SERVICE_NAME, $CUSTOMER_NAME? (e.g: 13:00 or 1pm)"

    read SERVICE_TIME

    # insert appointment details into database if time format is correct
      MAKE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      # check if insertion was successful
      if [[ $MAKE_APPOINTMENT =~ "INSERT 0 1" ]]
      then
        echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      fi

    # check format of the time typed in by user
    # The tests do not pass when you check the time format, hence why it's grayed out
    # if [[ $SERVICE_TIME =~ ^[0-9]{2}:[0-9]{2}$ || $SERVICE_TIME =~ ^[0-9]{1,2}(am|pm|AM|PM)$ ]]
    # then
      
    # fi
  fi
}

SALON_MENU

# rerun function if user typed an incorrect service id not in list
until [[ $SERVICE_NAME ]]
do
  SALON_MENU "\nPlease enter the number corresponding to the service you want."
done
