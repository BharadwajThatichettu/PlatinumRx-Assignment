def convert_minutes():
    try:
       
        total_minutes = int(input("Enter total minutes: "))
        
        
        hours = total_minutes // 60
        minutes = total_minutes % 60
        
        print(f"Result: {hours} hrs {minutes} minutes")
    except ValueError:
        print("Invalid input! Please enter a numeric integer value.")

if __name__ == "__main__":
    convert_minutes()