@isTest
public class NumberTOWordConvertionTest {

    @isTest
    static void testGetNumberTOWordConvertion() {
        // Create a test instance of the NumberTOWordConvertion class
        NumberTOWordConvertion converter = new NumberTOWordConvertion();

        // Positive Test Cases
        Decimal positiveValue1 = 12345.67;
        String result1 = converter.getNumberTOWordConvertion(positiveValue1);
        system.debug('result1'+result1);
        System.assertEquals(' Twelve Thousand Three Hundred and Forty Five Rupees And  Sixty Seven Paisa Only', result1);

        Decimal positiveValue2 = 5000;
        String result2 = converter.getNumberTOWordConvertion(positiveValue2);
        system.debug('result2'+result2);
        System.assertEquals(' Five Thousand Rupees Only', result2);

        Decimal positiveValue3 = 987654321.99;
        String result3 = converter.getNumberTOWordConvertion(positiveValue3);
        system.debug('result3'+result3);
        System.assertEquals(' Ninety Eight Crore Seventy Six Lakh Fifty Four Thousand Three Hundred and Twenty One Rupees And  Ninety Nine Paisa Only', result3);


    }


}