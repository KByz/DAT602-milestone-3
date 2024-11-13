using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace dust2dustpart3
{
    public class Game
    {
        private int? _gameID;
        private string? _runtime;
        private string? _status;



        // Class statics
        public static Game? CurrentGame { get; set; }

        public static List<Game> lcGames = new List<Game>();

        // Control
        public Boolean Update = false;
        public Then? then;

        // Properties
        public int? gameID
        {
            get { return _gameID; }
            set
            {
                _gameID = value;
                //if (Update) updateData();
            }
        }
        public string? runtime
        {
            get { return _runtime; }
            set
            {
                _runtime = value;
                // if (Update) updateData();
            }
        }

        public string? status
        {
            get { return _status; }
            set
            {
                _status = value;
                // if (Update) updateData();
            }
        }



        // Editor GUI
        public void Edit(Then pRunNext)
        {
            then = pRunNext;
            EditAccount editor = new EditAccount();
            editor.Show();
        }

        public void UpdateData()
        {
            if (this.Update == true)
            {
                // this.updateData();
                if (this.gameID == Game.CurrentGame.gameID)
                {
                    Game.CurrentGame.Update = false;
                    Game.CurrentGame.gameID = this.gameID;
                    Game.CurrentGame.runtime = this.runtime;
                    Game.CurrentGame.status = this.status;
                }
                this.Update = false;
            }

        }

        public Game? tile_form;
        public PictureBox? TileDisplay;

        public static List<Game.Tile> lcTiles = new List<Game.Tile>();
        public string? username { get; internal set; }

        /*
        private void newGame()
        {
            if (_gameID != null)
            {
                clsGameDAO dbAccess = new clsGameDAO();
                dbAccess.NewGame(_gameID, _runtime, _status);
            }

        } */


        public class Map
        {
            private int? _mapID;
            private int? _gameID;

        }


        public class Tile
        {
            private int? _tileID { get; set; }
            private int? _mapID { get; set; }
            private int? _row { get; set; }
            private int? _col { get; set; }
            private int? _tileType { get; set; }
            private int? _npcID { get; set; }
            private int? _itemID { get; set; }
            private string? _username { get; set; }
            private TimeSpan? _movementTimer { get; set; }


            // -- a BIT gnarlly - assigned to a PictureBox Click in UserGameForm constructor
            public void EgPictureBox_Click(object sender, EventArgs e, Game tile_form)
            {
                PictureBox selection = (PictureBox)sender;

                if (tile_form != null)
                {

                    

                }
            }

        }

    }

}




