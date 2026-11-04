# %%
import pandas as pd
import sqlalchemy


# definição de função query do banco
def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query


query = import_query("life_cycle.sql")
print(query)


# %%
# conexção com o banco de dados
engine_app = sqlalchemy.create_engine("sqlite:///../../data/loyalty_system/database.db")
engine_analytical = sqlalchemy.create_engine(
    "sqlite:///../../data/analytics/database.db"
)
# %%
dates = [
    "2025-01-01",
    "2025-01-02",
    "2025-01-03",
    "2025-01-04",
    "2025-01-05",
    "2025-01-06",
    "2025-01-07",
    "2025-01-08",
    "2025-01-09",
    "2025-01-10",
    "2025-01-11",
    "2025-01-12",
    "2025-01-13",
    "2025-01-14",
    "2025-01-15",
    "2025-01-16",
    "2025-01-17",
    "2025-01-18",
    "2025-01-19",
    "2025-01-20",
    "2025-01-21",
    "2025-01-22",
    "2025-01-23",
    "2025-01-24",
    "2025-01-25",
    "2025-01-26",
    "2025-01-27",
    "2025-01-28",
    "2025-01-29",
    "2025-01-30",
    "2025-01-31",
]
for i in dates:
    with engine_analytical.connect() as con:
        con.execute(
            sqlalchemy.text("DELETE FROM life_cycle WHERE dtRef = date('{i}','-1 day')")
        )
        con.commit()

    print(i)
    query_format = query.format(date=i)
    df = pd.read_sql_query(query_format, engine_app)
    df.to_sql("life_cycle", engine_analytical, if_exists="append", index=False)

# %%
