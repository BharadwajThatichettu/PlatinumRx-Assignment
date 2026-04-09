def remove_duplicates():
    
    input_string = input("Enter a string: ")
    
    result = ""
    
  
    for char in input_string:
    
        if char not in result:
            result += char
            
    print(f"String after removing duplicates: {result}")

if __name__ == "__main__":
    remove_duplicates()