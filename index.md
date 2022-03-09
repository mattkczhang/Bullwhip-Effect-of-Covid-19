## Demand Shock along the Supply Chain: The Bullwhip Effect of Covid-19 in Chinese Exports

<img width="994" alt="Trade and Covid (abs)" src="https://user-images.githubusercontent.com/94136772/157398285-0428a85c-7e92-452d-8454-31336cd12614.png">

### Abstract

This study investigates the bullwhip effect of Covid-19 on global supply chains from the Chinese perspective. The bullwhip effect refers to the amplification of demand shock along the supply chain, and my baseline estimates show that a 1% increase in foreign new cases (a proxy for foreign demand shock) reduces exports of downstream products and that of upstream industries by 2.1% and 4.5% respectively. The estimates also suggest that whether industries are concentrated or not generates ambiguous effects on exports that vary from different empirical specifications. In addition, a heterogeneity analysis suggests that the bullwhip effect is stronger in regional supply chains among geographically proximate countries and countries that are closely connected in terms of the trade volume. Furthermore, a dynamic analysis shows that the outbreak of Covid-19 in foreign countries causes a lagged import substitution towards Chinese products that reverses the initially negative demand shock. Unlike the initial adverse effect, I find that the lagged import substitution does not amplify along the supply chain, but mostly affects downstream industries.

### Theoretical Model

<img width="994" alt="Model_graph" src="https://user-images.githubusercontent.com/94136772/157398135-821c62be-1764-4969-9e0d-d78e7ed879dc.png">

The graph above presents the bullwhip effect model. The green line indicates the economic shock on upstream industries and the blue line indicates the shock on downstream industries. The model suggests that 
- upstream producers suffer from a stronger shock and stronger post-shock fluctuation compared to downstream producers. 
- the shock will not hit upstream producers immediately and there is a time lag between the shock and the change in demand. 

### Data

The Chinese exports data is published by the General Administration of Customs of the People’s Republic of China (GACC). It records the Chinese export trade value in US dollars at monthly frequency from January 2019 to September 2020 at the Chinese Province-Foreign Country-two digit Harmonized System (HS) commodity level. The full sample consists of 97 commodity classes exported from 31 Chinese provinces to 243 foreign countries.

The Chinese Covid data is published in the monthly reports of China’s National Health Commission and the global Covid data is reported by the European Center for Disease Prevention and Control (ECDC). Both Chinese and foreign Covid data include the number of confirmed cases and deaths from January to September 2020 at the province/foreign country level (Note that the data from ECDC only includes the statistics for 212 countries).

The upstreamness index data comes from Antràs, Chor, Fally, and Hillberry (2012) who measure the upstreamness index of different industries in the United States and examine the applicability of the index to other countries.

### Conclusion

In this paper, I study the bullwhip effect of Covid-19 along the global supply chain from the Chinese perspective. My baseline estimates suggest that upstream industries tend to suffer from a stronger negative demand shock compared to downstream industries while concentrated industries in vast majority of the cases tend to have a weaker demand shock, which is consistent with the bullwhip effect theory. Specifically, a 1% increase in foreign new cases reduces Chinese exports by 2.6% for downstream industries, 4.7% for upstream industries, and 5.5% for both upstream and concentrated industries. These results are robust across different fixed effect specifications, measurements of Covid severity, and sample restrictions. A heterogeneity analysis indicates that the bullwhip effect tends to be stronger in the supply chains in which countries are geographically proximate and are more closely connected in terms of the trade volume.

A dynamic analysis of the bullwhip effect, however, indicates some deviations from the theory. On one hand, the bullwhip effect model mathematically suggests that upstream industries tend to face a stronger demand shock at a later time as the inventory adjustments can amplify the shock that takes n period to transmit through the supply chain. On the other hand, my estimates show that (1) the initial Covid-led demand shock hits downstream and upstream industries in the same month; (2) the change in exports of downstream and upstream industries turns from negative to positive, and the fluctuation of upstream exports is weaker than that of downstream exports, which is at odds with the bullwhip effect model. While the first deviations can be explained by the frequency of my trade data and the rapid information transmission given the high-tech communication technology nowadays, the second one cannot be fully explicated without the supplemental import substitutions theory. In short, it is the shut-down of foreign industrial production and the corresponding import substitution that leads to increasing demand for Chinese downstream final goods and decreasing demand for Chinese upstream raw or intermediate goods.

My study also sheds light upon the current Covid policies across different countries, suggesting that the global industrial recovery needs the combination of both demand and supply side supports from better control of the pandemic. Blindly reopening the economy is theoretically ineffective. In detail, countries like the United States, India, Brazil, France, and Italy need to strengthen their Covid-19 prevention measures to handle their over ten thousand daily new cases in February 2021. When the pandemic is to some extent under control, industrial production can be normalized (supply side) and consumers’ income can be recuperated (demand side). In this case, a gradual Covid-prevention accompanying with economic reopening can not only effectively smooth out the fluctuation generated by the bullwhip effect but also reduce the inefficiency caused by the import substitution. 

From the global perspective, the regional and international corporation in Covid-19 prevention is also crucial in today’s interconnected world. On one hand, regional trade is proved to be more volatile based on my heterogeneity analysis of the bullwhip effect, so cooperation among East Asian countries, for example, can theoretically promote their trade recoveries. On the other hand, as international trade accounts for 60.27% of the world GDP in 2019 according to the World Bank data, world economy and global supply chains are easily affected by the pandemic as long as it hits at least one country that engages in the trade. Therefore international cooperation is the only way to mitigate the potential damage of the pandemic.

While the bullwhip effect plus the import substitution theory provide some insights of the Covid-led demand shock across Chinese industries, future studies can conduct a more comprehensive analysis by including the complete 2020 and 2021 trade data, the inventory data, the import data, and more accurate upstream and concentration index. In addition, as my study mainly focuses on the global supply chains from the Chinese perspective, it is also worth examining the ones from the perspectives of the United States and the European Union and check if the bullwhip effect and the import substitution can be generalized to the foreign trade of these countries. Lastly, future analysis of the Covid impacts on Chinese exports can test whether the bullwhip effect and the import substitution is long-lasting. Politically, the pandemic-induced restructuring and reshaping of global trade and GVCs will promote the change of trade policies in many countries. Economically, although the bullwhip effect plus the import substitution that fluctuate Chinese exports may not be persistent, it is possible that certain micro adjustments in global and/or regional supply chains can be enduring as some producers have the chance to explore other possible trading partners and ways of trading. Covid-19 is drastically reshaping the world not only medically but also economically.

### Software Usage

- `Stata` is used to conduct data cleaning, visualization, and regression analysis.
- `Overleaf` is used to complie the paper.
- `Microsoft Excel` is used to create and manipulate simple tabular data.

### Author

Kaichong (Matt) Zhang

Advised by Professor Felix L Friedt
