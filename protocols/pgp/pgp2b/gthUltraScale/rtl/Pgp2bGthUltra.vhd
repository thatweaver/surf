-------------------------------------------------------------------------------
-- File       : Pgp2bGthUltra.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2013-06-29
-- Last update: 2017-11-13
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- This file is part of 'Example Project Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'Example Project Firmware', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.Pgp2bPkg.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity Pgp2bGthUltra is
   generic (
      TPD_G             : time                 := 1 ns;
      AXIL_ERROR_RESP_G : slv(1 downto 0) := AXI_RESP_DECERR_C;
      ----------------------------------------------------------------------------------------------
      -- PGP Settings
      ----------------------------------------------------------------------------------------------
      TX_POLARITY_G     : sl                   := '0';
      RX_POLARITY_G     : sl                   := '0';
      TX_ENABLE_G       : boolean              := true;
      RX_ENABLE_G       : boolean              := true;
      PAYLOAD_CNT_TOP_G : integer              := 7;  -- Top bit for payload counter
      VC_INTERLEAVE_G   : integer              := 0;  -- Interleave Frames
      NUM_VC_EN_G       : integer range 1 to 4 := 4);
   port (
      -- GT Clocking
      stableClk        : in  sl;        -- GT needs a stable clock to "boot up"
      stableRst        : in  sl;
      gtRefClk         : in  sl;
      -- Gt Serial IO
      pgpGtTxP         : out sl;
      pgpGtTxN         : out sl;
      pgpGtRxP         : in  sl;
      pgpGtRxN         : in  sl;
      -- Tx Clocking
      pgpTxReset       : in  sl;
      pgpTxOutClk      : out sl;        -- recovered clock
      pgpTxClk         : in  sl;
      pgpTxMmcmLocked  : in  sl;
      -- Rx clocking
      pgpRxReset       : in  sl;
      pgpRxOutClk      : out sl;        -- recovered clock
      pgpRxClk         : in  sl;
      pgpRxMmcmLocked  : in  sl;
      -- Non VC Rx Signals
      pgpRxIn          : in  Pgp2bRxInType;
      pgpRxOut         : out Pgp2bRxOutType;
      -- Non VC Tx Signals
      pgpTxIn          : in  Pgp2bTxInType;
      pgpTxOut         : out Pgp2bTxOutType;
      -- Frame Transmit Interface - 1 Lane, Array of 4 VCs
      pgpTxMasters     : in  AxiStreamMasterArray(3 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
      pgpTxSlaves      : out AxiStreamSlaveArray(3 downto 0);
      -- Frame Receive Interface - 1 Lane, Array of 4 VCs
      pgpRxMasters     : out AxiStreamMasterArray(3 downto 0);
      pgpRxMasterMuxed : out AxiStreamMasterType;
      pgpRxCtrl        : in  AxiStreamCtrlArray(3 downto 0);
      -- AXI-Lite DRP interface
      axilClk          : in  sl;
      axilRst          : in  sl;
      axilReadMaster   : in  AxiLiteReadMasterType;
      axilReadSlave    : out AxiLiteReadSlaveType;
      axilWriteMaster  : in  AxiLiteWriteMasterType;
      axilWriteSlave   : out AxiLiteWriteSlaveType);
end Pgp2bGthUltra;

architecture mapping of Pgp2bGthUltra is

   signal resetGtSync : sl;
   signal gtHardReset : sl;

   -- PgpRx Signals
   signal gtRxUserReset : sl;
   signal phyRxLaneIn   : Pgp2bRxPhyLaneInType;
   signal phyRxLaneOut  : Pgp2bRxPhyLaneOutType;
   signal phyRxReady    : sl;
   signal phyRxInit     : sl;

   -- PgpTx Signals
   signal gtTxUserReset : sl;
   signal phyTxLaneOut  : Pgp2bTxPhyLaneOutType;
   signal phyTxReady    : sl;

begin

   gtRxUserReset <= phyRxInit or pgpRxReset or pgpRxIn.resetRx;
   gtTxUserReset <= pgpTxReset or pgpTxIn.resetTx;

   U_RstSync_1: entity work.RstSync
      generic map (
         TPD_G           => TPD_G,
         OUT_REG_RST_G   => true)
      port map (
         clk      => stableClk,               -- [in]
         asyncRst => pgpTxIn.resetGt,          -- [in]
         syncRst  => resetGtSync);          -- [out]
   
   gtHardReset <= resetGtSync or stableRst;

   U_Pgp2bLane : entity work.Pgp2bLane
      generic map (
         LANE_CNT_G        => 1,
         VC_INTERLEAVE_G   => VC_INTERLEAVE_G,
         PAYLOAD_CNT_TOP_G => PAYLOAD_CNT_TOP_G,
         NUM_VC_EN_G       => NUM_VC_EN_G,
         TX_ENABLE_G       => TX_ENABLE_G,
         RX_ENABLE_G       => RX_ENABLE_G)
      port map (
         pgpTxClk         => pgpTxClk,
         pgpTxClkRst      => pgpTxReset,
         pgpTxIn          => pgpTxIn,
         pgpTxOut         => pgpTxOut,
         pgpTxMasters     => pgpTxMasters,
         pgpTxSlaves      => pgpTxSlaves,
         phyTxLanesOut(0) => phyTxLaneOut,
         phyTxReady       => phyTxReady,
         pgpRxClk         => pgpRxClk,
         pgpRxClkRst      => pgpRxReset,
         pgpRxIn          => pgpRxIn,
         pgpRxOut         => pgpRxOut,
         pgpRxMasters     => pgpRxMasters,
         pgpRxMasterMuxed => pgpRxMasterMuxed,
         pgpRxCtrl        => pgpRxCtrl,
         phyRxLanesOut(0) => phyRxLaneOut,
         phyRxLanesIn(0)  => phyRxLaneIn,
         phyRxReady       => phyRxReady,
         phyRxInit        => phyRxInit);

   --------------------------
   -- Wrapper for GTH IP core
   --------------------------
   PgpGthCoreWrapper_1 : entity work.PgpGthCoreWrapper
      generic map (
         TPD_G             => TPD_G,
         AXIL_ERROR_RESP_G => AXIL_ERROR_RESP_G)
      port map (
         stableClk      => stableClk,
         stableRst      => gtHardReset,
         gtRefClk       => gtRefClk,
         gtRxP          => pgpGtRxP,
         gtRxN          => pgpGtRxN,
         gtTxP          => pgpGtTxP,
         gtTxN          => pgpGtTxN,
         rxReset        => gtRxUserReset,
         rxUsrClkActive => pgpRxMmcmLocked,
         rxResetDone    => phyRxReady,
         rxUsrClk       => pgpRxClk,
         rxData         => phyRxLaneIn.data,
         rxDataK        => phyRxLaneIn.dataK,
         rxDispErr      => phyRxLaneIn.dispErr,
         rxDecErr       => phyRxLaneIn.decErr,
         rxPolarity     => RX_POLARITY_G,
         rxOutClk       => pgpRxOutClk,
         txReset        => gtTxUserReset,
         txUsrClk       => pgpTxClk,
         txUsrClkActive => pgpTxMmcmLocked,
         txResetDone    => phyTxReady,
         txData         => phyTxLaneOut.data,
         txDataK        => phyTxLaneOut.dataK,
         txPolarity     => TX_POLARITY_G,
         txOutClk       => pgpTxOutClk,
         loopback       => pgpRxIn.loopback,
	 axilRst         => axilRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave);

end mapping;
