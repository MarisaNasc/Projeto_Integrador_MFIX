
import os
import pandas as pd
from sqlalchemy import create_engine

pasta_script = os.path.dirname(os.path.abspath(__file__))

caminho_csv = os.path.join(pasta_script,'24p26.csv')

engine = create_engine(
    "postgresql+psycopg2://postgres:23062006@localhost:5432/Mfix_BD"
)

df_mov = pd.read_csv(
    caminho_csv,
    sep=';',
    encoding='utf-8-sig'
)


# REMOVE COLUNAS FANTASMAS
df_mov = df_mov.loc[
    :,
    ~df_mov.columns.str.contains('^Unnamed')
]


df_mov.to_sql(
    'mov_estoque',
    engine,
    if_exists='append',
    index=False
)

print("IMPORTAÇÃO FINALIZADA")
