import snowflake.connector

def execute_sql_file(sql_file):
    # Connect to Snowflake using provided credentials
    try:
        conn = snowflake.connector.connect(
            account='gxkmoso-pb31214',
            user='SANJAY',
            password='Temp@123$',
            warehouse='COMPUTE_WH',
            role='ACCOUNTADMIN'
        )
        
        with open(sql_file, 'r') as f:
            sql = f.read()

        # Split the SQL file into individual statements (assuming each statement is terminated by a semicolon)
        sql_statements = sql.split(';')

        with conn.cursor() as cursor:
            for statement in sql_statements:
                statement = statement.strip()
                if statement:
                    cursor.execute(statement)

                    # Fetch and print results if any
                    try:
                        results = cursor.fetchall()
                        for row in results:
                            print(row)
                    except snowflake.connector.errors.ProgrammingError:
                        print("No results to fetch.")
    
    except snowflake.connector.errors.Error as e:
        print(f"An error occurred: {e}")
    
    finally:
        conn.close()

if __name__ == "__main__":
    execute_sql_file('sql_file.sql')
