import snowflake.connector
import sys

def execute_sql_file(sql_file):
    # Check if file name is provided
    if len(sys.argv) != 2:
        print("Usage: python script.py <sql_filename>")
        sys.exit(1)
    
    try:
        # Connect to Snowflake
        conn = snowflake.connector.connect(
            account='gxkmoso-pb31214',
            user='SANJAY',
            password='Temp@123$',
            warehouse='COMPUTE_WH',
            role='ACCOUNTADMIN'
        )
        print("Connected to Snowflake")

        # Read SQL file
        with open(sql_file, 'r') as f:
            sql = f.read()

        # Execute SQL statements
        with conn.cursor() as cursor:
            for statement in sql.split(';'):
                statement = statement.strip()
                if statement:  # Skip empty statements
                    print(f"\nExecuting SQL: {statement}")
                    cursor.execute(statement)
                    
                    # Try to fetch results
                    try:
                        results = cursor.fetchall()
                        for row in results:
                            print(row)
                    except:
                        pass  # Statement had no results to fetch

    except FileNotFoundError:
        print(f"Error: File '{sql_file}' not found")
    except Exception as e:
        print(f"Error: {str(e)}")
    finally:
        if 'conn' in locals():
            conn.close()
            print("\nConnection closed")

if __name__ == "__main__":
        execute_sql_file(sys.argv[1])
