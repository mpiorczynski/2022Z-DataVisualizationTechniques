library(PogromcyDanych)
library(dplyr)

colnames(auta2012)
dim(auta2012)
head(auta2012[,-ncol(auta2012)])
sum(is.na(auta2012))

## 1. Z którego rocznika jest najwięcej aut i ile ich jest?
  auta2012 %>% group_by(Rok.produkcji) %>% 
               summarise(ilosc = n()) %>%
               arrange(-ilosc) %>%
               head(1)

## Odp: 
    #Najwiecej samochodow jest z roku 2011 i jest ich 17 418

## 2. Która marka samochodu występuje najczęściej wśród aut wyprodukowanych w 2011 roku?
  auta2012 %>% filter(Rok.produkcji == "2011") %>% 
               group_by(Marka) %>%
               summarise(ilosc = n()) %>% 
               arrange(-ilosc) %>% 
               head(1)

## Odp:
    #Najczesciej wystepujaca marka samochodu wsrod samochodow wyprodukowanych w
    #roku 2011 jest skoda

## 3. Ile jest aut z silnikiem diesla wyprodukowanych w latach 2005-2011?
  auta2012 %>% 
              filter(Rok.produkcji >= 2005 & Rok.produkcji <= 2011 & Rodzaj.paliwa == 'olej napedowy (diesel)') %>% 
              summarise(ilosc = n())

## Odp:
    #Jest ich 59534

## 4. Spośród aut z silnikiem diesla wyprodukowanych w 2011 roku, która marka jest średnio najdroższa?
  auta2012 %>% filter(Rok.produkcji == "2011" & Rodzaj.paliwa == 'olej napedowy (diesel)') %>% 
               group_by(Marka) %>% 
               summarise(srednia_cena = mean(Cena.w.PLN)) %>%
               arrange(-srednia_cena) %>%
               head(1)

## Odp:
    #Najdrozsza marka sposrod samochodwo wyprodukowanych w roku 2011 z silnikiem diesla jest Porshe

## 5. Spośród aut marki Skoda wyprodukowanych w 2011 roku, który model jest średnio najtańszy?
  auta2012 %>% filter(Marka == "Skoda" & Rok.produkcji == "2011") %>%
               group_by(Model) %>%
               summarise(srednia_cena = mean(Cena.w.PLN)) %>% 
               arrange(srednia_cena) %>% 
               head(1) 

## Odp:
    #Fabia

## 6. Która skrzynia biegów występuje najczęściej wśród 2/3-drzwiowych aut,
##    których stosunek ceny w PLN do KM wynosi ponad 600?
  auta2012 %>% filter(Liczba.drzwi == "2/3" & (Cena.w.PLN / KM) > 600) %>% 
               group_by(Skrzynia.biegow) %>% 
               summarise(ilosc = n()) %>% 
               arrange(-ilosc) %>% 
               head(1)

## Odp: 
    #najczesciej wystepuje automatyczna

## 7. Spośród aut marki Skoda, który model ma najmniejszą różnicę średnich cen 
##    między samochodami z silnikiem benzynowym, a diesel?
  library(tidyr)
    auta2012 %>% filter(Marka == "Skoda" & (Rodzaj.paliwa == "benzyna" | Rodzaj.paliwa == "olej napedowy (diesel)")) %>% 
                 group_by(Model, Rodzaj.paliwa) %>%
                 summarise(srednia_cena = mean(Cena.w.PLN)) %>% 
                 arrange(Model) %>%
                 pivot_wider(names_from = Rodzaj.paliwa, values_from = srednia_cena) %>% 
                 mutate(roznica = abs(benzyna - `olej napedowy (diesel)`)) %>%
                 arrange(roznica) %>% 
                 select(Model, roznica) %>% 
                 head(1)
                 
                  
## Odp: 
    #najmniejsza roznice srednic cen miedzy samochodami z silnikiem beznynowym a dieslem ma Felicia

## 8. Znajdź najrzadziej i najczęściej występujące wyposażenie/a dodatkowe 
##    samochodów marki Lamborghini
    library(stringr)
    
    Lamborghini_dataFrame <- auta2012 %>% filter(Marka == "Lamborghini")
    list <- str_split(as.character(Lamborghini_dataFrame$Wyposazenie.dodatkowe), ", ")
    equipment <- unlist(list)
    equipment_n <- data.frame(equipment) %>% group_by(equipment) %>%
                   summarise(amount = n())
    #najrzadziej
    equipment_n %>% arrange(amount) %>% head(1)
    #najczesciej
    equipment_n %>% arrange(-amount) %>% head(1)

## Odp: 
    #najrzadziej blokada skrzyni biegow - 1
    #najczesciej ABS - 18

## 9. Porównaj średnią i medianę mocy KM między grupami modeli A, S i RS 
##    samochodów marki Audi
    auta2012 %>% filter(Marka == "Audi") %>% 
    mutate(Model.General = case_when(str_starts(Model, "A") ~ "A" , str_starts(Model, "S") ~ "S" , str_starts(Model, "RS") ~ "RS", TRUE ~ "Other")) %>%
    filter(Model.General != "Other") %>%
    group_by(Model.General) %>%
    summarise(srednia_moc = mean(KM, na.rm = TRUE), mediana_moc = median(KM, na.rm = TRUE))

## Odp:
    #dla modelu A: srednia moc = 160 a mediana 140, dla modelu RS srednia moc to 500, a mediana 450 oraz dla modelu S
    #srednia moc to 344 a mediana 344

## 10. Znajdź marki, których auta występują w danych ponad 10000 razy.
##     Podaj najpopularniejszy kolor najpopularniejszego modelu dla każdej z tych marek.
      
        auta_10000 <- auta2012 %>% group_by(Marka) %>%
                      summarise(amount = n()) %>%
                      filter(amount > 10000)
        naj_modele <- auta2012 %>% filter(Marka %in% auta_10000$Marka) %>% 
                      group_by(Marka,Model) %>% 
                      summarise(n = n()) %>% 
                      top_n(1)
        naj_modele %>% inner_join(auta2012) %>% 
                       group_by(Marka, Model, Kolor) %>% 
                       summarise(n = n()) %>% 
                       top_n(1) %>% 
                       select(Marka, Model, Kolor)
        
        
## Odp: 
    #Audi A4 czarny-metalic, BMW 320 srebrny-metalic, Ford Focus srebrny-metalic, Mercedes-Benz C 220 srebrny-metalic,
    #Oper Astra srebrny-metalic, Renault Megane srebrny-metalic, Volkswagen Passat srebrny-metalic
        