#!/bin/bash

# Room management
declare -A rooms=(
    ["101"]="Single Room"
    ["102"]="Double Room"
    ["103"]="Suite"
    ["104"]="Deluxe Room"
)
declare -A customers
declare -A inventory=( 
    ["Daal Chawal"]=150
    ["Biryani"]=250
    ["Mix Vegetable"]=120
    ["Chicken Karahi"]=300
    ["Burger"]=200
    ["Sandwich"]=150
    ["Pizza"]=500
    ["Fries"]=100
)

# room_count=0
customer_count=0

# ANSI color codes for styling
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
RESET="\033[0m"

# Function to add a room
add_room() {
    echo -e "${CYAN}Enter Room Number: ${RESET}"
    read room_no
    echo -e "${CYAN}Comfort (View/Without View): ${RESET}"
    read type
    echo -e "${CYAN}Size (D/S): ${RESET}"
    read size
    rooms[$room_no]="$size $type"
    echo -e "${GREEN}Room $room_no added successfully!${RESET}"
}

# Function to view all rooms
view_rooms() {
    echo -e "${YELLOW}Listing all rooms:${RESET}"
    for room_no in "${!rooms[@]}"; do
        echo -e "${CYAN}Room $room_no: ${rooms[$room_no]}${RESET}"
    done
}

delete_room() {
    echo -e "${CYAN}Enter Room Number to delete: ${RESET}"
    read room_no
    if [[ -v rooms[$room_no] ]]; then      #Checks if the specified variable or array key exists.
      unset "rooms[$room_no]"
        echo -e "${GREEN}Room $room_no deleted successfully!${RESET}"
    else
        echo -e "${RED}Room $room_no not found.${RESET}"
    fi
}


# Function to update a room
update_room() {
    echo -e "${CYAN}Enter room no. you want to update: ${RESET}"
    read room_no
    if [[ -n ${rooms[$room_no]} ]]; then
        echo -e "${CYAN}Enter new room number: ${RESET}"
        read new_room_no
        echo -e "${CYAN}Comfort (View/Without View): ${RESET}"
        read type
        echo -e "${CYAN}Size (D/S):${RESET} "
        read size  
        # Remove the old room and add the new room
        unset "rooms[$room_no]"
        rooms[$new_room_no]="$size $type"
        
        echo -e "${GREEN}Room updated successfully.${RESET}"
    else
        echo -e "${RED}Room not found.${RESET}"
    fi
}


# Function to register a customer (booking)
booking() {
    customer_count=$((customer_count + 1))
    echo -e "${YELLOW}*****Fill the form*****${RESET}"
    echo -e "${CYAN}Enter your name: ${RESET}"
    read name
    echo -e "${CYAN}Enter your email: ${RESET}"
    read email

    # Check if the email is already registered
    for id in "${!customers[@]}"; do
        existing_email=$(echo "${customers[$id]}" | awk '{print $2}')
        if [[ "$existing_email" == "$email" ]]; then
            echo -e "${RED}Email $email is already registered!${RESET}"
            return
        fi
    done

    echo -e "${CYAN}Enter your phone number: ${RESET}"
    read phone
    echo -e "${CYAN}Enter your CNIC: ${RESET}"
    read CNIC
    echo -e "${CYAN}Enter your city: ${RESET}"
    read city

    # Store customer registration details
    customers[$customer_count]="$name $email $phone $CNIC $city"
    echo -e "${GREEN}Customer $name registered successfully!${RESET}"
}

# Function to check in a customer
checkin() {
    echo -e "${CYAN}Enter your email: ${RESET}"
    read email

    # Find customer by email
    bookingId=""
    for id in "${!customers[@]}"; do
        registered_email=$(echo "${customers[$id]}" | awk '{print $2}')
        if [[ "$registered_email" == "$email" ]]; then
            bookingId=$id
            break
        fi
    done

    # Check if email is registered
    if [[ -z $bookingId ]]; then
        echo -e "${RED}Email $email is not registered! Please register first.${RESET}"
        return
    fi

    # Check if email is already used for check-in
    if [[ $(echo "${customers[$bookingId]}" | wc -w) -gt 5 ]]; then
        echo -e "${RED}Email $email is already used for a check-in!${RESET}"
        return
    fi

    echo -e "${CYAN}Customer Details: ${RESET}"
    echo -e "${CYAN}${customers[$bookingId]}${RESET}"

    echo -e "${CYAN}Enter room number: ${RESET}"
    read roomNo

    # Check if the room exists
    if [[ -z ${rooms[$roomNo]} ]]; then
        echo -e "${RED}Room $roomNo does not exist!${RESET}"
        return
    fi

    # Check if the room is already booked
    if [[ ${rooms[$roomNo]} == "Booked" ]]; then
        echo -e "${RED}Room $roomNo is already booked!${RESET}"
        return
    fi

    echo -e "${CYAN}Enter from date: ${RESET}"
    read from_date
    echo -e "${CYAN}Enter to date: ${RESET}"
    read to_date
    echo -e "${CYAN}Enter how many days you want to stay: ${RESET}"
    read days
    echo -e "${CYAN}Enter advance payment: ${RESET}"
    read advance

    # Mark the room as booked
    rooms[$roomNo]="Booked"

    # Update customer details with check-in information
    customers[$bookingId]="${customers[$bookingId]} $roomNo $from_date $to_date $days $advance"

    echo -e "${GREEN}*****Checked-In Successfully!!*****${RESET}"
}

# Function to check out a customer
checkout() {
    echo -e "${CYAN}Enter the email of the customer to check out: ${RESET}"
    read email

    # Find customer by email
    bookingId=""
    for id in "${!customers[@]}"; do
        registered_email=$(echo "${customers[$id]}" | awk '{print $2}')
        if [[ "$registered_email" == "$email" ]]; then
            bookingId=$id
            break
        fi
    done

    # Check if email is registered
    if [[ -z $bookingId ]]; then
        echo -e "${RED}Email $email is not registered!${RESET}"
        return
    fi

    # Check if the customer has checked in
    customer_string="${customers[$bookingId]}"
    IFS=' ' read -r name email phone cnic city roomNo fromDate toDate days advance <<< "$customer_string"

    if [[ -z $roomNo ]]; then # check if var is empty
        echo -e "${RED}Customer $name has not checked in yet!${RESET}"
        return
    fi

    echo -e "${YELLOW}******** Check-Out Details *********${RESET}"
    rent=1000  # Example rent per day
    totalAmount=$((days * rent))

    echo -e "${CYAN}Customer Name: $name${RESET}"
    echo -e "${CYAN}Room Number: $roomNo${RESET}"
    echo -e "${CYAN}Stay Duration: $days day(s)${RESET}"
    echo -e "${RED}Total Rent: $totalAmount${RESET}"
    echo -e "${YELLOW}Advance Paid: $advance${RESET}"

    totalPayable=$((totalAmount - advance))
    echo -e "${GREEN}Total Payable: $totalPayable${RESET}"

    echo -e "${CYAN}Confirm checkout? (yes/no): ${RESET}"
    read confirm
    if [[ "$confirm" != "yes" ]]; then
        echo -e "${RED}Checkout cancelled.${RESET}"
        return
    fi

    # Release the room
    rooms[$roomNo]="Available"

    # Remove the customer from the system
    unset "customers[$bookingId]"
    echo -e "${GREEN}Customer $name has been successfully checked out!${RESET}"

    # Display updated customer list
    view_customers
}


updateCust() {
    echo -e "${YELLOW}Enter the email of the customer you want to update: ${RESET}"
    read updateEmail

    # Search for the customer by email
    bookingId=""
    for id in "${!customers[@]}"; do
        customer_string="${customers[$id]}"
        registered_email=$(echo "$customer_string" | awk '{print $2}') # echo customer string Outputs the value of customer_string as input for further processing.
        if [[ "$registered_email" == "$updateEmail" ]]; then        # AWK allows you to manipulate data and generate reports, extract sepecific field
            bookingId=$id
            break
        fi
    done

    if [[ -z $bookingId ]]; then
        echo -e "${RED}Email not found!${RESET}"
        return
    fi

    echo -e "${GREEN}Updating data for Booking ID: $bookingId${RESET}"

    echo -e "${CYAN}Enter new name (leave blank to keep current): ${RESET}"
    read name
    echo -e "${CYAN}Enter new phone number (leave blank to keep current): ${RESET}"
    read phone
    echo -e "${CYAN}Enter new CNIC (leave blank to keep current): ${RESET}"
    read cnic
    echo -e "${CYAN}Enter new city (leave blank to keep current): ${RESET}"
    read city
    echo -e "${CYAN}Enter new room number (leave blank to keep current): ${RESET}"
    read roomNo
    echo -e "${CYAN}Enter new from date (leave blank to keep current): ${RESET}"
    read fromDate
    echo -e "${CYAN}Enter new to date (leave blank to keep current): ${RESET}"
    read toDate
    echo -e "${CYAN}Enter new number of days (leave blank to keep current): ${RESET}"
    read days
    echo -e "${CYAN}Enter new advance payment (leave blank to keep current): ${RESET}"
    read advance

    # Update details only if new data is provided
    customer_string="${customers[$bookingId]}"
    IFS=' ' read -r old_name old_email old_phone old_cnic old_city old_roomNo old_fromDate old_toDate old_days old_advance <<< "$customer_string"
    #sets the Internal Field Separator to a space, assigns the split values to the respective variables, <<< used as input
    name=${name:-$old_name}
    phone=${phone:-$old_phone}
    cnic=${cnic:-$old_cnic}
    city=${city:-$old_city}
    roomNo=${roomNo:-$old_roomNo}
    fromDate=${fromDate:-$old_fromDate}
    toDate=${toDate:-$old_toDate}
    days=${days:-$old_days}
    advance=${advance:-$old_advance}

    # Store the updated data back into the customers array
    customers[$bookingId]="$name $old_email $phone $cnic $city $roomNo $fromDate $toDate $days $advance"
    echo -e "${GREEN}******Successfully updated******${RESET}"
}

# Function to view all available rooms and food for customer
view_details() {
    echo -e "${YELLOW}Available Rooms:${RESET}"
    view_rooms
    echo -e "${YELLOW}Food Menu:${RESET}"
    viewInventory
}

# Function to view all customers
view_customers() {
    echo -e "${YELLOW}Listing all customers:${RESET}"
    if [ ${#customers[@]} -eq 0 ]; then
        echo -e "${RED}No customers currently checked in.${RESET}"
    else
        for id in "${!customers[@]}"; do
            customer_string="${customers[$id]}"
            IFS=' ' read -r name email phone cnic city roomNo fromDate toDate days advance <<< "$customer_string"
            echo -e "${CYAN}Booking ID: $id - Name: $name, Email: $email, Phone: $phone, Room: ${roomNo:-N/A}, Dates: ${fromDate:-N/A} to ${toDate:-N/A}, Days: ${days:-N/A}, Advance: ${advance:-N/A}${RESET}"
        done
    fi
}

viewInventory() {
    echo -e "${YELLOW}View Food Menu${RESET}"
    for item in "${!inventory[@]}"; do
        echo -e "${CYAN}$item - ${inventory[$item]} PKR${RESET}"
    done
    echo -e "${GREEN}1. Back to main menu${RESET}"
    read choice
    case $choice in
        1) return;;
        *) echo -e "${RED}Invalid option, try again!" ${RESET}; viewInventory ;;
    esac
}

# Admin functions for adding, updating, and deleting food
addFood() {
    echo -e "${CYAN}Enter Food Item Name: ${RESET}"
    read foodItem
    echo -e "${CYAN}Enter Price of $foodItem: ${RESET}"
    read foodPrice
    inventory["$foodItem"]=$foodPrice
    echo -e "${GREEN}Food item added successfully!${RESET}"
}

updateFood() {
    echo -e "${CYAN}Enter Food Item to Update: ${RESET}"
    read foodItem
    if [[ -v inventory["$foodItem"] ]]; then
        echo -e "${CYAN}Enter new price for $foodItem:${RESET} "
        read newPrice
        inventory["$foodItem"]=$newPrice
        echo -e "${GREEN}$foodItem updated successfully!${RESET}"
    else
        echo -e "${RED}Food item not found!${RESET}"
    fi

}

deleteFood() {
    echo -e "${CYAN}Enter Food Item to Delete: ${RESET}"
    read foodItem
    if [[ -v inventory["$foodItem"] ]]; then
         unset "inventory[$foodItem]"
        echo -e "${CYAN}$foodItem deleted successfully!${RESET}"
    else
        echo -e "${RED}Food item not found!${RESET}"
    fi
}

# Function for Customer to order food
order_food() {
    local total=0
    declare -A selected_items=()

    echo -e "${CYAN}Available Food Menu:${RESET}"
    for item in "${!inventory[@]}"; do
        echo -e "${CYAN}$item - ${inventory[$item]} PKR${RESET}"
    done

    while true; do
        echo -e "${CYAN}Enter the food item you want to order (or type 'done' to finish):${RESET}"
        read orderChoice
        if [[ $orderChoice == "done" ]]; then
            echo -e "${YELLOW}Order Summary:${RESET}"
            for item in "${!selected_items[@]}"; do
                echo -e "${CYAN}$item - ${selected_items[$item]} PKR${RESET}"
            done
            echo -e "${YELLOW}Total: $total PKR${RESET}"
            echo -e "${GREEN}Thank you for your order!${RESET}"
            break
        elif [[ -v inventory["$orderChoice"] ]]; then
            selected_items["$orderChoice"]=${inventory[$orderChoice]}
            total=$((total + inventory[$orderChoice]))
            echo -e "${GREEN}Added $orderChoice to your order!${RESET}"
        else
            echo -e "${RED}Invalid choice. Please try again.${RESET}"
        fi
    done
}
# Login function to authenticate users
login() {
    local user_role="$1"
    clear
    echo -e "${BLUE}Hotel Management System Login (${user_role^})${RESET}"
    echo -e "${CYAN}Enter Username: ${RESET}"
    read username
    echo -e "${CYAN}Enter Password: ${RESET}"
    read -s password
    echo 

    if [[ $user_role == "admin" && $username == "admin" && $password == "admin123" ]]; then
        echo -e "${GREEN}Admin login successful!${RESET}"
        admin_panel
    elif [[ $user_role == "customer" && $username == "customer" && $password == "cust123" ]]; then
        echo -e "${GREEN}Customer login successful!${RESET}"
        customer_panel
    else
        echo -e "${RED}Invalid credentials. Please try again.${RESET}"
        sleep 1
        login "$user_role"
    fi
}
# Function for initial role selection
select_role() {
    clear
    echo -e "${BLUE}Welcome to the Hotel Management System${RESET}"
    echo -e "${YELLOW}1. Admin Login${RESET}"
    echo -e "${YELLOW}2. Customer Login${RESET}"
    echo -e "${YELLOW}3. Exit${RESET}"
    echo -e "${CYAN}Choose your role: ${RESET}"
    read role_choice
    case $role_choice in
        1) login "admin" ;;
        2) login "customer" ;;
        3) echo -e "${GREEN}Exiting...${RESET}"; exit 0 ;;
        *) echo -e "${RED}Invalid choice. Please try again.${RESET}"; sleep 1; select_role ;;
    esac
}

# Admin panel function
admin_panel() {
    clear
    echo -e "${BLUE}Admin Panel${RESET}"
    while true; do
        echo -e "${YELLOW}1. Manage Rooms${RESET}"
        echo -e "${YELLOW}2. Manage Customers${RESET}"
        echo -e "${YELLOW}3. Manage Inventory${RESET}"
        echo -e "${YELLOW}4. Logout${RESET}"
        echo -e "${CYAN}Choose an option: ${RESET}"
        read choice
        case $choice in
            1)
                echo -e "${YELLOW}1. Add Room 2. View Rooms 3. Delete Room 4. Update Room 5. Back to Admin Panel 6. Logout${RESET}"
                read option
                case $option in
                    1) add_room ;;
                    2) view_rooms ;;
                    3) delete_room ;;
                    4) update_room ;;
                    5) continue ;;
                    6) select_role ;;
                    *) echo -e "${RED}Invalid option${RESET}";;
                esac
                ;;
            2)
                echo -e "${YELLOW}1. View Customers 2. Delete Customer 3. Update Customer 4. Back to Admin Panel 5. Logout${RESET}"
                read option
                case $option in
                    1) view_customers ;;
                    2) checkout ;;
                    3) updateCust ;;
                    4) continue ;;
                    5) select_role ;;
                    *) echo -e "${RED}Invalid option${RESET}";;
                esac
                ;;
            3)
                echo -e "${YELLOW}1. Add Food 2. Update Food 3. Delete Food 4. View Food 5. Back to Admin Panel 6. Logout${RESET}"
                read option
                case $option in
                1) addFood ;;
                2) updateFood ;;
                3) deleteFood ;;
                4) viewInventory ;;
                5) continue ;;
                6) select_role ;;
                *) echo "Invalid option, try again!" ; 
                 esac
                ;;
            4)
                echo -e "${GREEN}Logging out...${RESET}"
                sleep 1
                select_role
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${RESET}"
                ;;
        esac
    done
}

# Customer panel function
customer_panel() {
    clear
    echo -e "${CYAN}Customer Panel${RESET}"
    while true; do
        echo -e "${YELLOW}1. view_details 2. Booking 3. Check-in 4. Order Food 5. Back to customer panel 6. Logout${RESET}"
        read choice
        case $choice in
            1) view_details ;;
            2) booking ;;
            3) checkin ;;
            4) order_food ;;
            5) continue ;;
            6) select_role ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${RESET}"
                ;;
        esac
    done
}

# Initial call to start the program
select_role
