﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace BlockchainDemonstratorApi.Models.Classes
{
    public class GameMaster
    {
        [Key]
        public string Id { get; set; }
        [Required]
        public virtual Game Game { get; set; }
    }
}
