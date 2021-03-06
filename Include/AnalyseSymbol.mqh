//+----------------------------+
//|   Analyze Currency Symbol  |
//+============================+
//|
//|   Rev Date: 2010.06.07
//|
//|   Contains the following Functions:
//|
//|   GetSymbolType()
//|   GetBasePairForCross()
//|   GetCounterPairForCross()
//|   GetSymbolLeverage()
//|   AnalyzeSymbol()
//|
//+----------------------------+

#property copyright "1005phillip"
#include <stderror.mqh>
#include <stdlib.mqh>
#include <CUtils.mqh>

//+---------------------------------------------------------------------------------------------------------------------------------------+
//|   GetSymbolType()                                                                                                                        |
//|=======================================================================================================================================|
//|   int GetSymbolType(string symbol, bool verbose=false)                                                                                                  |
//|                                                                                                                                       |
//|   Analyzes Symbol() to determine the SymbolType for use with Profit/Loss and lotsize calcs.                                           |
//|   The function returns an integer value which is the SymbolType.                                                                      |
//|   An integer value of 6 for SymbolType is returned in the event of an error                                                           |
//|                                                                                                                                       |
//|   Parameters:                                                                                                                         |
//|                                                                                                                                       |
//|      verbose     -  Determines whether Print messages are committed to the experts log. By default, print messages are disabled.      |
//|                                                                                                                                       |
//|   Examples:                                                                                                                           |
//|                                                                                                                                       |
//|      SymbolType 1:  symbol  = USDJPY                                                                                                 |
//|                     Base    = USD                                                                                                        |
//|                     Counter = JPY                                                                                                     |
//|                                                                                                                                       |
//|      SymbolType 2:  symbol  = EURUSD                                                                                                 |
//|                     Base    = EUR                                                                                                        |
//|                     Counter = USD                                                                                                     |
//|                                                                                                                                       |
//|      SymbolType 3:  symbol  = CHFJPY                                                                                                 |
//|                     Base    = CHF                                                                                                        |
//|                     Counter = JPY                                                                                                     |
//|                     USD is base to the base currency pair - USDCHF                                                                    |
//|                     USD is base to the counter currency pair - USDJPY                                                                 |
//|                                                                                                                                       |
//|      SymbolType 4:  symbol) = AUDCAD                                                                                                 |
//|                     Base    = AUD                                                                                                        |
//|                     Counter = CAD                                                                                                      |
//|                     USD is counter to the base currency pair - AUDUSD                                                                 |
//|                     USD is base to the counter currency pair - USDCAD                                                                 |
//|                                                                                                                                       |
//|      SymbolType 5:  symbol  = EURGBP                                                                                                  |
//|                     Base    = EUR                                                                                                        |
//|                     Counter = GBP                                                                                                     |
//|                     USD is counter to the base currency pair - EURUSD                                                                 |
//|                     USD is counter to the counter currency pair - GBPUSD                                                              |
//|      SymbolType 6:  Error occurred, SymbolType could not be identified                                                                |
//|                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------+
int GetSymbolType(string symbol, bool verbose=true)
{ 
   int     calculatedSymbolType=6;
   string  currentSymbol="",symbolBase="",symbolCounter="",postfix="",calculatedBasePairForCross="",calculatedCounterPairForCross="";  
   currentSymbol = symbol;
   
   string currency = AccountCurrency();
   symbolBase      = StringSubstr(currentSymbol, 0, 3);
   symbolCounter   = StringSubstr(currentSymbol, 3, 3);
   postfix         = StringSubstr(currentSymbol, 6);
   if(symbolBase    == currency) calculatedSymbolType = 1;
   if(symbolCounter == currency) calculatedSymbolType = 2;
   if((calculatedSymbolType == 1 || calculatedSymbolType == 2) && verbose == true) 
   {
      Print("Base currency is ",symbolBase," and the Counter currency is ", symbolCounter," (this pair is a major)");
   }
   
  
   if (calculatedSymbolType != 1 && calculatedSymbolType != 2)
   {
      if (_utils.GetLotSize(StringConcatenate(currency, symbolCounter, postfix)) > 0)
      {
         calculatedSymbolType          = 4; // SymbolType can also be 3 but this will be determined later when the Base pair is identified
         calculatedCounterPairForCross = StringConcatenate(currency, symbolCounter, postfix);
      }
      else if (_utils.GetLotSize(StringConcatenate(symbolCounter, currency, postfix)) > 0)
      {
         calculatedSymbolType          = 5;
         calculatedCounterPairForCross = StringConcatenate(symbolCounter, currency, postfix);
      }

      // Determine if currency is the COUNTER currency or the BASE currency for the BASE currency forming Symbol()
      if (_utils.GetLotSize(StringConcatenate(currency, symbolBase, postfix)) > 0)
      {
         calculatedSymbolType       = 3;
         calculatedBasePairForCross = StringConcatenate(currency, symbolBase, postfix);
      }
      else if(_utils.GetLotSize(StringConcatenate(symbolBase, currency, postfix)) > 0)
      {
         calculatedBasePairForCross = StringConcatenate(symbolBase, currency, postfix);
      }
   }
   return calculatedSymbolType;
}  // SymbolType body end


//+---------------------------------------------------------------------------------------------------------------------------------------+
//|   GetBasePairForCross()                                                                                                                  |
//|=======================================================================================================================================|
//|   string GetBasePairForCross(string symbol, bool verbose=false)                                                                                         |
//|                                                                                                                                       |
//|   Analyzes Symbol() to determine if currency is the COUNTER currency or the BASE currency for the BASE currency in Symbol()  |
//|   in the event that Symbol() is a cross-currency financial instrument.                                                                |
//|   Returns a text string with the name of the financial instrument which is the base currency pair to Symbol() if possible,            |
//|   otherwise, it returns an empty string.                                                                                              |
//|                                                                                                                                       |
//|   Parameters:                                                                                                                         |
//|                                                                                                                                       |
//|      verbose     -  Determines whether Print messages are committed to the experts log. By default, print messages are disabled.      |
//|                                                                                                                                       |
//|   Sample:                                                                                                                             |
//|                                                                                                                                       |
//|      // Symbol()=CHFJPY                                                                                                               |
//|      // currency=USD                                                                                                         |
//|      string   CrossBasePair=GetBasePairForCross();   // USD is base to the base currency pair - USDCHF                                   |
//|      Print("The base pair for the cross-currency instrument ",Symbol()," is ",CrossBasePair);                                         |
//|                                                                                                                                       |
//|   Examples:                                                                                                                           |
//|                                                                                                                                       |
//|      SymbolType 3:  Symbol() = CHFJPY                                                                                                 |
//|                     Base     = CHF                                                                                                        |
//|                     Counter  = JPY                                                                                                     |
//|                     USD is base to the base currency pair - USDCHF                                                                    |
//|                     USD is base to the counter currency pair - USDJPY                                                                 |
//|                                                                                                                                       |
//|      SymbolType 4:  Symbol() = AUDCAD                                                                                                 |
//|                     Base    = AUD                                                                                                        |
//|                     Counter = CAD                                                                                                      |
//|                     USD is counter to the base currency pair - AUDUSD                                                                 |
//|                     USD is base to the counter currency pair - USDCAD                                                                 |
//|                                                                                                                                       |
//|      SymbolType 5:  Symbol() = EURGBP                                                                                                 |
//|                     Base    = EUR                                                                                                        |
//|                     Counter = GBP                                                                                                     |
//|                     USD is counter to the base currency pair - EURUSD                                                                 |
//|                     USD is counter to the counter currency pair - GBPUSD                                                              |
//|                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------+
string GetBasePairForCross(string symbol, bool verbose=false)
{  
   string   currentSymbol="",symbolBase="",symbolCounter="",postfix="",calculatedBasePairForCross="";
   currentSymbol = symbol;
   //if(verbose==true) Print("Account currency is ", currency," and Current Symbol = ",currentSymbol);

   symbolBase    = StringSubstr(currentSymbol, 0, 3);
   symbolCounter = StringSubstr(currentSymbol, 3, 3);
   postfix       = StringSubstr(currentSymbol, 6);
   string currency = AccountCurrency();
   switch( GetSymbolType(currentSymbol) ) // Determine if currency is the COUNTER currency or the BASE currency for the BASE currency forming Symbol()
   {
      case 1:  
      break;
      
      case 2:  
      break;
      
      case 3:  
         calculatedBasePairForCross = StringConcatenate(currency, symbolBase, postfix);
      break;
      
      case 4:  
         calculatedBasePairForCross = StringConcatenate(symbolBase, currency, postfix);
      break;
      
      case 5:  
         calculatedBasePairForCross = StringConcatenate(symbolBase, currency, postfix);
      break;
      
      case 6:  
         Print("Error occurred while identifying GetSymbolType(), calculated GetSymbolType() = 6"); 
      break;
      
      default:  
         Print("Error encountered in the SWITCH routine for identifying BasePairForCross on financial instrument ",currentSymbol); // The expression did not generate a case value
      break;   
   }
   return calculatedBasePairForCross;
}  // BasePairForCross body end

//+---------------------------------------------------------------------------------------------------------------------------------------+
//|   GetCounterPairForCross()                                                                                                               |
//|=======================================================================================================================================|
//|   string GetCounterPairForCross(bool verbose=false)                                                                                      |
//|                                                                                                                                       |
//|   Analyzes Symbol() to determine if currency is the COUNTER currency or the BASE currency for the COUNTER currency in        |
//|   Symbol() in the event that Symbol() is a cross-currency financial instrument.                                                       |
//|   Returns a text string with the name of the financial instrument which is the counter currency pair to Symbol() if possible,         |
//|   otherwise, it returns an empty string.                                                                                              |
//|                                                                                                                                       |
//|   Parameters:                                                                                                                         |
//|                                                                                                                                       |
//|      verbose     -  Determines whether Print messages are committed to the experts log. By default, print messages are disabled.      |
//|                                                                                                                                       |
//|   Sample:                                                                                                                             |
//|                                                                                                                                       |
//|      // Symbol()=CHFJPY                                                                                                               |
//|      // currency=USD                                                                                                         |
//|      string   CrossCounterPair=GetCounterPairForCross();   // USD is base to the counter currency pair - USDJPY                          |
//|      Print("The counter pair for the cross-currency instrument ",Symbol()," is ",CrossCounterPair);                                   |
//|                                                                                                                                       |
//|   Examples:                                                                                                                           |
//|                                                                                                                                       |
//|      SymbolType 3:  Symbol() = CHFJPY                                                                                                 |
//|                                                                                                                                       |
//|                     Base = CHF                                                                                                        |
//|                     Counter = JPY                                                                                                     |
//|                                                                                                                                       |
//|                     USD is base to the base currency pair - USDCHF                                                                    |
//|                                                                                                                                       |
//|                     USD is base to the counter currency pair - USDJPY                                                                 |
//|                                                                                                                                       |
//|      SymbolType 4:  Symbol() = AUDCAD                                                                                                 |
//|                                                                                                                                       |
//|                     Base = AUD                                                                                                        |
//|                     Counter = CAD                                                                                                     |
//|                                                                                                                                       |
//|                     USD is counter to the base currency pair - AUDUSD                                                                 |
//|                                                                                                                                       |
//|                     USD is base to the counter currency pair - USDCAD                                                                 |
//|                                                                                                                                       |
//|      SymbolType 5:  Symbol() = EURGBP                                                                                                 |
//|                                                                                                                                       |
//|                     Base = EUR                                                                                                        |
//|                     Counter = GBP                                                                                                     |
//|                                                                                                                                       |
//|                     USD is counter to the base currency pair - EURUSD                                                                 |
//|                                                                                                                                       |
//|                     USD is counter to the counter currency pair - GBPUSD                                                              |
//|                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------+
string GetCounterPairForCross(string symbol, bool verbose=false)
{  
   string   currentSymbol="",symbolBase="",symbolCounter="",postfix="",calculatedCounterPairForCross="";
   currentSymbol = symbol;
  // if(verbose==true) Print("Account currency is ", currency," and Current Symbol = ",currentSymbol);
   symbolBase    = StringSubstr(currentSymbol,0, 3);
   symbolCounter = StringSubstr(currentSymbol,3, 3);
   postfix       = StringSubstr(currentSymbol,6);
   string currency = AccountCurrency();

   switch( GetSymbolType(currentSymbol) ) // Determine if currency is the COUNTER currency or the BASE currency for the COUNTER currency forming Symbol()
   {
      case 1:  
      break;
      
      case 2:  
      break;
      
      case 3:  
         calculatedCounterPairForCross = StringConcatenate(currency, symbolCounter, postfix);
      break;
      
      case 4:  
         calculatedCounterPairForCross = StringConcatenate(currency, symbolCounter, postfix);
      break;
      
      case 5:  
         calculatedCounterPairForCross = StringConcatenate(symbolCounter, currency, postfix);
      break;
      
      case 6:  
         Print("Error occurred while identifying GetSymbolType(), calculated GetSymbolType() = 6"); 
      break;
      
      default:  
         Print("Error encountered in the SWITCH routine for identifying CounterPairForCross on financial instrument ",currentSymbol); // The expression did not generate a case value
      break;   
   }
   
   return calculatedCounterPairForCross;
}  // CounterPairForCross body end

//+---------------------------------------------------------------------------------------------------------------------------------------+
//|   GetSymbolLeverage()                                                                                                                    |
//|=======================================================================================================================================|
//|   int GetSymbolLeverage(bool verbose=false)                                                                                              |
//|                                                                                                                                       |
//|   Analyzes Symbol() to determine the broker's required leverage for the financial instrument.                                         |
//|   Returns an integer value representing leverage ratio if possible, otherwise, it returns a zero value.                               |
//|                                                                                                                                       |
//|   Parameters:                                                                                                                         |
//|                                                                                                                                       |
//|      verbose     -  Determines whether Print messages are committed to the experts log. By default, print messages are disabled.      |
//|                                                                                                                                       |
//|   Sample:                                                                                                                             |
//|                                                                                                                                       |
//|      // Symbol()=CHFJPY                                                                                                               |
//|      // currency=USD                                                                                                         |
//|      int   calculatedLeverage=GetSymbolLeverage();   // Leverage for USDJPY is set to 100:1                                           |
//|      Print("Leverage for ",Symbol()," is set at ",calculatedLeverage,":1");                                                           |
//|                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------+
int GetSymbolLeverage(string symbol, bool verbose=false)
{  // SymbolLeverage body start
   double      calculatedLeverage=0;
   string      currentSymbol="",calculatedBasePairForCross="";

   currentSymbol = symbol;
   switch(GetSymbolType(currentSymbol)) // Determine the leverage for the financial instrument based on the instrument's SymbolType (major, cross, etc)
   {
      case 1:  
         calculatedLeverage = NormalizeDouble(_utils.GetLotSize(currentSymbol) / _utils.RequiredMargin(currentSymbol),2); 
      break;
      
      case 2:  
         calculatedLeverage = NormalizeDouble(_utils.AskPrice(currentSymbol)*_utils.GetLotSize(currentSymbol)/_utils.RequiredMargin(currentSymbol),2); 
      break;
      
      case 3:  
         calculatedBasePairForCross = GetBasePairForCross(currentSymbol);
         calculatedLeverage = NormalizeDouble(2*_utils.GetLotSize(currentSymbol)/((_utils.BidPrice(calculatedBasePairForCross)+_utils.AskPrice(calculatedBasePairForCross))*_utils.RequiredMargin(currentSymbol)),2); 
      break;
      
      case 4:  
         calculatedBasePairForCross = GetBasePairForCross(currentSymbol);
         calculatedLeverage = NormalizeDouble(_utils.GetLotSize(currentSymbol)*(_utils.BidPrice(calculatedBasePairForCross)+_utils.AskPrice(calculatedBasePairForCross))/(2*_utils.RequiredMargin(currentSymbol)),2); 
      break;
      
      case 5:  
         calculatedBasePairForCross = GetBasePairForCross(currentSymbol);
         calculatedLeverage = NormalizeDouble(_utils.GetLotSize(currentSymbol)*(_utils.BidPrice(calculatedBasePairForCross)+_utils.AskPrice(calculatedBasePairForCross))/(2*_utils.RequiredMargin(currentSymbol)),2); 
      break;
      
      case 6:  
         Print("Error occurred while identifying GetSymbolType(), calculated GetSymbolType() = 6"); 
      break;
      
      default:  
         Print("Error encountered in the SWITCH routine for calculating Leverage on financial instrument ",currentSymbol); // The expression did not generate a case value
      break;
   }
   if(verbose==true) Print("Leverage for ",currentSymbol," is set at ",calculatedLeverage,":1");
   return (int)(calculatedLeverage);
}  // SymbolLeverage body end

//+------------------------------------------------------------------------------------------------+
//| AnalyzeSymbol()                                                                                |
//|================================================================================================|
//| Analysis routines for characterizing the resultant trade metrics                               |
//+------------------------------------------------------------------------------------------------+
void AnalyzeSymbol(string symbol)
{  
   double   calculatedLeverage=0,calculatedMarginRequiredLong=0,calculatedMarginRequiredShort=0;
   int      calculatedSymbolType=0,ticket=0,lotSizeDigits=0,CurrentOrderType=0;
   string   currentSymbol="",symbolBase="",symbolCounter="",postfix="",calculatedBasePairForCross="",calculatedCounterPairForCross="";

   currentSymbol=symbol;
   symbolBase    = StringSubstr(currentSymbol,0,3);
   symbolCounter = StringSubstr(currentSymbol,3,3);
   postfix       = StringSubstr(currentSymbol,6);
   calculatedSymbolType = GetSymbolType(currentSymbol);
   if(calculatedSymbolType == 6)
   {
      return;
   }

   calculatedLeverage = GetSymbolLeverage(currentSymbol);
   switch(calculatedSymbolType) // Determine the Base and Counter pairs for the financial instrument based on the instrument's SymbolType (major, cross, etc)
   {
      case 1:  
      break;
      
      case 2:  
      break;
      
      case 3:  
         calculatedBasePairForCross    = GetBasePairForCross(currentSymbol);
         calculatedCounterPairForCross = GetCounterPairForCross(currentSymbol);
      break;
      
      case 4:  
         Print("Base currency is ",symbolBase," and the Counter currency is ",symbolCounter," (this pair is a cross)");
         calculatedBasePairForCross    = GetBasePairForCross(currentSymbol);
         calculatedCounterPairForCross = GetCounterPairForCross(currentSymbol);
      break;
      
      case 5:  
         Print("Base currency is ",symbolBase," and the Counter currency is ",symbolCounter," (this pair is a cross)");
         calculatedBasePairForCross    = GetBasePairForCross(currentSymbol);
         calculatedCounterPairForCross = GetCounterPairForCross(currentSymbol);
      break;
      
      default:  
         Print("Error encountered in the SWITCH routine for reporting on financial instrument ",currentSymbol); // The expression did not generate a case value
      break;
   }

   switch(calculatedSymbolType) // Determine the margin required to open 1 lot position for the financial instrument based on the instrument's SymbolType (major, cross, etc)
   {
      case 1:  
         calculatedMarginRequiredLong = NormalizeDouble(_utils.GetLotSize(currentSymbol)/calculatedLeverage,2);
      break;
      
      case 2:  
         calculatedMarginRequiredLong  = NormalizeDouble(_utils.AskPrice(currentSymbol)*_utils.GetLotSize(currentSymbol)/calculatedLeverage,2);
         calculatedMarginRequiredShort = NormalizeDouble(_utils.BidPrice(currentSymbol)*_utils.GetLotSize(currentSymbol)/calculatedLeverage,2);
      break;
      
      case 3:  
         calculatedMarginRequiredLong = NormalizeDouble(2*_utils.GetLotSize(currentSymbol)/((_utils.BidPrice(calculatedBasePairForCross)+_utils.AskPrice(calculatedBasePairForCross))*calculatedLeverage),2);
      break;
      
      case 4:  
         calculatedMarginRequiredLong = NormalizeDouble(_utils.GetLotSize(currentSymbol)*(_utils.BidPrice(calculatedBasePairForCross)+_utils.AskPrice(calculatedBasePairForCross))/(2*calculatedLeverage),2);
      break;
      
      case 5:  
         calculatedMarginRequiredLong = NormalizeDouble(_utils.GetLotSize(currentSymbol)*(_utils.BidPrice(calculatedBasePairForCross)+_utils.AskPrice(calculatedBasePairForCross))/(2*calculatedLeverage),2);
      break;
      
      default:  
         Print("Error encountered in the SWITCH routine for calculating required margin for financial instrument ",currentSymbol); // The expression did not generate a case value
      break;
   }
   lotSizeDigits =(int) -MathRound(MathLog(_utils.GetLotStep(currentSymbol))/MathLog(10.)); // Number of digits after decimal point for the Lot for the current broker, like Digits for symbol prices
}  // AnalyzeSymbol body end
