#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to Diezma's Salon, how can I help you?\n"

SERVICES_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Display services
  GET_SERVICE=$($PSQL "SELECT service_id, name FROM services")
  echo "$GET_SERVICE" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # Get input
  read SERVICE_ID_SELECTED

  # If input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # Send to main menu
    SERVICES_MENU "That is not a valid service number."
  else
    # Get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    GET_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # If customer doesn't exist
    if [[ -z $GET_CUSTOMER_NAME ]]
    then
      # Get new customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # Insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      GET_CUSTOMER_NAME=$CUSTOMER_NAME
    fi

    # Ask for time of appointment
    echo -e "\nWhat time would you like your appointment,$GET_CUSTOMER_NAME?"
    read SERVICE_TIME
    
    # Insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES((SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'), $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
    then
      echo -e "\nI have put you down for a$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED") at $SERVICE_TIME, $GET_CUSTOMER_NAME."
    else
      echo -e "\nThere was an error scheduling your appointment. Please try again."
    fi
  fi
}

SERVICES_MENU