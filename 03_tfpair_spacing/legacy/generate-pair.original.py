# Initializing a sample list
my_list =["ALX4", "ARGFX", "ARID5B", "BAZ2A", "BHLHA15", "CEBPD", "CEBPG", "CPHXL2", "CPHXL", "CREB1", "CRX", "DLX3", "DPRX", "DUX4", "DUXA", "DUXB", "E2F1", "E2F3", "EGR3", "EHF", "ELF1", "ELF2", "ELF3", "ELF4", "ELF5", "ELK1", "ELK4", "ERF", "ERG", "ESR1", "ETS1", "ETS2", "ETV1", "ETV2", "ETV3", "ETV3L", "ETV4", "ETV5", "ETV6", "ETV7", "FIGLA", "FLI1", "FOS", "FOXA1", "FOXA3", "FOXI1", "FOXJ2", "FOXJ3", "FOXL1", "FOXO1", "FOXQ1", "GABPA", "GABPB1", "GATA1", "GATA2", "GATA3", "GATA4", "GCM2", "GLI3-CL", "GLI3-FL", "GPBP1L1", "HES7", "HNF1A", "HNF1B", "HNF4A", "HOXA10", "HOXA11", "HOXA13", "HOXA1", "HOXA2", "HOXA3", "HOXA5", "HOXA9", "HOXB13", "HOXB2", "HOXD12", "HSF1", "HSF4", "IRF1", "IRF3", "IRF4", "IRF5", "IRF8", "IRF9", "ISX", "JAZF1", "KLF10", "KLF4", "KLF5", "KLF6", "KLF8", "LEUTX", "LHX1", "LHX2", "LHX3", "LHX4", "LHX6", "LHX8", "MAX", "MEF2A", "MYB", "MYC", "MYSM1", "NFATC3", "NFATC4", "NFIA", "NFIB", "NFIC", "NFIX", "NFKB1", "NFYA", "NFYC", "NKX2-5", "NR2F6", "OTX2", "PAX6", "PAX7", "PAX8", "PAX9", "PBX4", "PDX1", "PITX1", "POU2F1", "POU5F1", "PPARG", "PRDM1", "RFX1", "RFX2", "RFX3", "RFX5", "RFX6", "RFX8", "RREB1", "RXRA", "SATB1", "SATB2", "SIX4", "SIX5", "SKIL", "SMAD1", "SMAD5", "SOX10", "SOX15", "SOX17", "SOX2", "SOX4", "SOX5", "SOX6", "SOX9", "SP7", "SPDEF", "SPI1", "SPIB", "SPIC", "SPZ1", "STAT1", "STAT3", "STAT4", "STAT5A", "STAT5B", "TBR1", "TBX21", "TBXT", "TCF3", "TEAD1", "TEAD2", "TEAD3", "TEAD4", "TFAP2A", "TFAP2C", "TFAP4", "TLX1", "TLX2", "TLX3", "TPRX1", "TPRX2", "USF1", "VSX1", "XBP1", "YY1", "ZBTB1", "ZBTB33", "ZBTB38", "ZBTB7B", "ZBTB9", "ZGPAT", "ZHX2", "ZNF200", "ZNF263", "ZNF808"] 

pairs = []
for i in range(len(my_list)):
    for j in range(i + 1, len(my_list)):
        pairs.append((my_list[i], my_list[j]))

print(pairs)

