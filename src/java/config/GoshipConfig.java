package config;

public class GoshipConfig {
    // API URLs
    public static final String API_URL = "https://sandbox.goship.io/api/v2";
    
    // Goship Token (lấy từ trang Developer của Goship)
    // Token này có thời hạn dài, không cần refresh qua OAuth2
    public static final String TOKEN = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjE5ZjQ0Yjg0ZTgzZThkYjE4Yjk5ZDY4MGNkMjU4N2MwZDJlOGEwYjRmOGYxYmIwZTgzOTJiMGJjYWVjNDE4ZDQ5YWJkYWU0YWNmOGU4NjFlIn0.eyJhdWQiOiIxMyIsImp0aSI6IjE5ZjQ0Yjg0ZTgzZThkYjE4Yjk5ZDY4MGNkMjU4N2MwZDJlOGEwYjRmOGYxYmIwZTgzOTJiMGJjYWVjNDE4ZDQ5YWJkYWU0YWNmOGU4NjFlIiwiaWF0IjoxNzY1NTIyODAwLCJuYmYiOjE3NjU1MjI4MDAsImV4cCI6MjA4MTA1NTYwMCwic3ViIjoiNDA0MSIsInNjb3BlcyI6W119.KCqlMitJ4sEe8tHSUMKS0Rcc52FjNTy7oBuPAzCAQEEMKeRst3kIprLkvoWXxgzPJlApLh-mDWySCgBAY_lkuqSyIohuXACC_ZAMlxQWz_pKs3ZaZCFNfO9fZ22mtJd2LElnqcg3PSZuVfhNApPdnAqihyTDj0lbhFnynstutQbs7Qt1E9pL76IWrThyF_f-VQ-KWW-4tuvHQf9Ceguyw6Ao_UkNEgjdsVzohOG0AZ-4XN_52iSZGPEvfBOCdD-31_L48i_HwZjoJ0tx7F4nW_FJQrMeRW1pzuHliv_e4GndoVr3GyteltRDE7agDtXRzHQmnV3WGfIxSUC3MLkiHZsIcmE8W8JAFUF8m0bVm-cyPhBd5Yi4KcilIwRldVCqSJ0Agv5TTVuo7skhWf8nRE-trkCQQF7RZpUIwVHtMHnsUhNkD1KMHxMuB7B1w-mtQMjyzaGh0jryv5KWymJTn_eeVSI9w5QpobPeTqugULTASa1_yhMPVJhC8LjBJ-beBlJReWBjy2pkllzXkWqoDILZDP9Vdn3ESLiCEtiFXTx0lBYuGHvksMgyJZwO-09Ny3zlTfR6lIQxAwG0b3GGi6VhAgprwplbPYVrwFq90nY8egGXEleIw8iKdLZHLl9mwJw4ywhXaBE_hqx1M4tX6EoM8ZrALTn6SkrKY8S2IsY";
    
    // Endpoints
    public static final String ENDPOINT_CITIES = "/cities";
    public static final String ENDPOINT_DISTRICTS = "/districts";
    public static final String ENDPOINT_WARDS = "/wards";
    public static final String ENDPOINT_RATES = "/rates";
    public static final String ENDPOINT_SHIPMENTS = "/shipments";
    
    // Shop address (địa chỉ kho hàng)
    public static final String SHOP_CITY = "Hà Nội";
    public static final String SHOP_DISTRICT = "Thạch Thất";
    public static final String SHOP_WARD = "Thạch Hòa";
    public static final String SHOP_ADDRESS = "Đại học FPT, Khu CNC Hòa Lạc";
}
