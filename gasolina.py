
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('gasolina.csv')

plt.plot(df['dia'], df['venda'])
plt.xlabel('Dia')
plt.ylabel('Preço de Venda')
plt.title('Preço Médio de Venda da Gasolina em São Paulo - Julho 2021')
plt.show()
