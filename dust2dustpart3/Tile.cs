
using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;

namespace dust2dustpart3
{
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
        public void EgPictureBox_Click(object sender, EventArgs e)
        {
            PictureBox selection = (PictureBox)sender;
            //MessageBox.Show("I am tile ID " + id.ToString() +". Jewel = "+jewel.ToString() + " Thorn = " + thorn.ToString());
            if (tile_form != null)
            {

            }
        }

        public Game? tile_form;
        public PictureBox? TileDisplay;

        public static List<Tile> lcTiles = new List<Tile>();

    }
}
