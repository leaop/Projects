import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

df = pd.read_csv("gasolina.csv")

plt.figure(figsize=(10, 6))
sns.lineplot(data=df, x='dia', y='venda')
plt.title('Preço Médio de Venda da Gasolina em São Paulo - Julho de 2021')
plt.xlabel('Dia de Julho')
plt.ylabel('Preço de Venda (R$)')
plt.grid(True)
plt.savefig("gasolina.png")
