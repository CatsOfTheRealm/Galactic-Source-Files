using System;
using System.Collections.Generic;
using System.Linq;
using common;
using common.resources;
using log4net;
using wServer.realm.terrain;

namespace wServer.realm.entities.vendors
{
    public class ShopItem : ISellableItem
    {
        public ushort ItemId { get; private set; }
        public int Price { get; }
        public int Count { get; }
        public string Name { get; }

        public ShopItem(string name, ushort price, int count = -1)
        {
            ItemId = ushort.MaxValue;
            Price = price;
            Count = count;
            Name = name;
        }

        public void SetItem(ushort item)
        {
            if (ItemId != ushort.MaxValue)
                throw new AccessViolationException("Can't change item after it has been set.");

            ItemId = item;
        }
    }

    internal static class MerchantLists
    {


        private static readonly ILog Log = LogManager.GetLogger(typeof(MerchantLists));
       
        private static readonly List<ISellableItem> Keys = new List<ISellableItem>
        { 
            new ShopItem("Snake Pit Key", 500),
            new ShopItem("Sprite World Key", 500),
            new ShopItem("Candy Key", 500),
            new ShopItem("Treasure Map", 500),
            new ShopItem("Undead Lair Key", 500),
            new ShopItem("Abyss of Demons Key", 500),
            new ShopItem("Manor Key", 500),
            new ShopItem("Theatre Key",  500),
            new ShopItem("Toxic Sewers Key", 500),
            new ShopItem("Lost Halls Key", 5000),
            new ShopItem("Oryx's Castle Key", 5000),
            new ShopItem("Lab Key", 750),
            new ShopItem("Shaitan's Key", 750),
            new ShopItem("Davy's Key", 750),
            new ShopItem("Mountain Temple Key", 500),
            new ShopItem("Ocean Trench Key", 750),
            new ShopItem("Crystal Cave Key", 750),
            new ShopItem("Forgotten Garden Key", 750),
            new ShopItem("Tomb of the Ancients Key", 750),
            new ShopItem("Woodland Labyrinth Key", 750),
            new ShopItem("Ice Tomb Key", 750),
            new ShopItem("Spectre's Lair Key", 750),
            new ShopItem("The Crawling Depths Key", 750),
            new ShopItem("Deadwater Docks Key", 750),
            new ShopItem("Ice Cave Key", 500),
            new ShopItem("Shatters Key", 1000),
            new ShopItem("Cultist Hideout Key", 20000)
        };

        private static readonly List<ISellableItem> PurchasableFameForGold = new List<ISellableItem>
        {
            new ShopItem("50 Fame", 125),
            new ShopItem("100 Fame", 250),
            new ShopItem("500 Fame", 1250),
            new ShopItem("1000 Fame", 2500),
            new ShopItem("5000 Fame", 12500)
        };

        private static readonly List<ISellableItem> PurchasableFame = new List<ISellableItem>
        {
            new ShopItem("50 Fame", 55),
            new ShopItem("100 Fame", 110),
            new ShopItem("500 Fame", 550),
            new ShopItem("1000 Fame", 1100),
            new ShopItem("5000 Fame", 5500)
        };

        private static readonly List<ISellableItem> Donator = new List<ISellableItem>
        {
            new ShopItem("Earth Scroll 3", 6000),//Trick White Bag
            new ShopItem("Earth Scroll 6", 4000),
            new ShopItem("Earth Scroll 9", 2500),
            new ShopItem("Trick White Bag", 250),
            new ShopItem("Loot Drop Potion", 3500),
        };


        private static readonly List<ISellableItem> Special = new List<ISellableItem>
        {
            new ShopItem("Amulet of Resurrection", 50000)
        };

        static void InitDyes(RealmManager manager)
        {
            var d1 = new List<ISellableItem>();
            var d2 = new List<ISellableItem>();
            foreach (var i in manager.Resources.GameData.Items.Values)
            {
                if (!i.Class.Equals("Dye"))
                    continue;

                if (i.Texture1 != 0)
                {
                    ushort price = 60;
                    if (i.ObjectId.Contains("Cloth") && i.ObjectId.Contains("Large"))
                        price *= 2;
                    d1.Add(new ShopItem(i.ObjectId, price));
                    continue;
                }

                if (i.Texture2 != 0)
                {
                    ushort price = 60;
                    if (i.ObjectId.Contains("Cloth") && i.ObjectId.Contains("Small"))
                        price *= 2;
                    d2.Add(new ShopItem(i.ObjectId, price));
                    continue;
                }
            }
           Shops[TileRegion.Store_10] = new Tuple<List<ISellableItem>, CurrencyType, int>(d1, CurrencyType.Fame, 0);
           Shops[TileRegion.Store_11] = new Tuple<List<ISellableItem>, CurrencyType, int>(d2, CurrencyType.Fame, 0);
        }

        public static readonly Dictionary<TileRegion, Tuple<List<ISellableItem>, CurrencyType, /*Rank Req*/int>> Shops =
            new Dictionary<TileRegion, Tuple<List<ISellableItem>, CurrencyType, int>>() { 
            { TileRegion.Store_5, new Tuple<List<ISellableItem>, CurrencyType, int>(Keys, CurrencyType.Fame, 0) },
            { TileRegion.Store_8, new Tuple<List<ISellableItem>, CurrencyType, int>(Special, CurrencyType.Fame, 0) },
            { TileRegion.Store_9, new Tuple<List<ISellableItem>, CurrencyType, int>(Donator, CurrencyType.Gold, 0) },
            { TileRegion.Store_14, new Tuple<List<ISellableItem>, CurrencyType, int>(PurchasableFame, CurrencyType.Fame, 0) },
            { TileRegion.Store_15, new Tuple<List<ISellableItem>, CurrencyType, int>(PurchasableFameForGold, CurrencyType.Gold, 0) },
        };
     
        public static void Init(RealmManager manager)
        {

            InitDyes(manager);
            foreach (var shop in Shops)
                foreach (var shopItem in shop.Value.Item1.OfType<ShopItem>())
                {
                    ushort id;
                    if (!manager.Resources.GameData.IdToObjectType.TryGetValue(shopItem.Name, out id))
                        Log.WarnFormat("Item name: {0}, not found.", shopItem.Name);
                    else
                        shopItem.SetItem(id);
                    
                }
        }
     
    }
}