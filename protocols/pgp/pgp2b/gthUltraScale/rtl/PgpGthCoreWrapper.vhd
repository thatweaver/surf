-------------------------------------------------------------------------------
-- File       : PgpGthCoreWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2013-06-29
-- Last update: 2017-11-07
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
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

entity PgpGthCoreWrapper is

   generic (
      TPD_G             : time            := 1 ns;
      AXIL_ERROR_RESP_G : slv(1 downto 0) := AXI_RESP_DECERR_C);
   port (
      stableClk : in sl;
      stableRst : in sl;

      -- GTH FPGA IO
      gtRefClk : in  sl;
      gtRxP    : in  sl;
      gtRxN    : in  sl;
      gtTxP    : out sl;
      gtTxN    : out sl;

      -- Rx ports
      rxReset        : in  sl;
      rxUsrClkActive : out sl;
      rxResetDone    : out sl;
      rxUsrClk       : out sl;
      rxUsrClk2      : out sl;
      rxUsrClkRst    : out sl;
      rxData         : out slv(15 downto 0);
      rxDataK        : out slv(1 downto 0);
      rxDispErr      : out slv(1 downto 0);
      rxDecErr       : out slv(1 downto 0);
      rxPolarity     : in  sl;
      rxOutClk       : out sl;

      -- Tx Ports
      txReset        : in  sl;
      txUsrClkActive : out sl;
      txResetDone    : out sl;
      txUsrClk       : out sl;
      txUsrClk2      : out sl;
      txUsrClkRst    : out sl;
      txData         : in  slv(15 downto 0);
      txDataK        : in  slv(1 downto 0);
      txOutClk       : out sl;
      txPolarity : in sl;
      loopback       : in  slv(2 downto 0);

      -- AXI-Lite DRP interface
      axilClk         : in  sl                     := '0';
      axilRst         : in  sl                     := '0';
      axilReadMaster  : in  AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
      axilWriteSlave  : out AxiLiteWriteSlaveType);

end entity PgpGthCoreWrapper;

architecture mapping of PgpGthCoreWrapper is

   component PgpGthCore
      port (
         gtwiz_userclk_tx_reset_in          : in  slv(0 downto 0);
         gtwiz_userclk_tx_srcclk_out        : out slv(0 downto 0);
         gtwiz_userclk_tx_usrclk_out        : out slv(0 downto 0);
         gtwiz_userclk_tx_usrclk2_out       : out slv(0 downto 0);
         gtwiz_userclk_tx_active_out        : out slv(0 downto 0);
         gtwiz_userclk_rx_reset_in          : in  slv(0 downto 0);
         gtwiz_userclk_rx_srcclk_out        : out slv(0 downto 0);
         gtwiz_userclk_rx_usrclk_out        : out slv(0 downto 0);
         gtwiz_userclk_rx_usrclk2_out       : out slv(0 downto 0);
         gtwiz_userclk_rx_active_out        : out slv(0 downto 0);
         gtwiz_reset_clk_freerun_in         : in  slv(0 downto 0);
         gtwiz_reset_all_in                 : in  slv(0 downto 0);
         gtwiz_reset_tx_pll_and_datapath_in : in  slv(0 downto 0);
         gtwiz_reset_tx_datapath_in         : in  slv(0 downto 0);
         gtwiz_reset_rx_pll_and_datapath_in : in  slv(0 downto 0);
         gtwiz_reset_rx_datapath_in         : in  slv(0 downto 0);
         gtwiz_reset_rx_cdr_stable_out      : out slv(0 downto 0);
         gtwiz_reset_tx_done_out            : out slv(0 downto 0);
         gtwiz_reset_rx_done_out            : out slv(0 downto 0);
         gtwiz_userdata_tx_in               : in  slv(15 downto 0);
         gtwiz_userdata_rx_out              : out slv(15 downto 0);
         drpaddr_in                         : in  slv(8 downto 0);
         drpclk_in                          : in  slv(0 downto 0);
         drpdi_in                           : in  slv(15 downto 0);
         drpen_in                           : in  slv(0 downto 0);
         drpwe_in                           : in  slv(0 downto 0);
         gthrxn_in                          : in  slv(0 downto 0);
         gthrxp_in                          : in  slv(0 downto 0);
         gtrefclk0_in                       : in  slv(0 downto 0);
         loopback_in                        : in  slv(2 downto 0);
         rx8b10ben_in                       : in  slv(0 downto 0);
         rxbufreset_in                      : in  slv(0 downto 0);
         rxcommadeten_in                    : in  slv(0 downto 0);
         rxmcommaalignen_in                 : in  slv(0 downto 0);
         rxpcommaalignen_in                 : in  slv(0 downto 0);
         rxpolarity_in                      : in  slv(0 downto 0);
         txpolarity_in                      : in  slv(0 downto 0);         
         tx8b10ben_in                       : in  slv(0 downto 0);
         txctrl0_in                         : in  slv(15 downto 0);
         txctrl1_in                         : in  slv(15 downto 0);
         txctrl2_in                         : in  slv(7 downto 0);
         drpdo_out                          : out slv(15 downto 0);
         drprdy_out                         : out slv(0 downto 0);
         gthtxn_out                         : out slv(0 downto 0);
         gthtxp_out                         : out slv(0 downto 0);
         gtpowergood_out                    : out slv(0 downto 0);
         rxbufstatus_out                    : out slv(2 downto 0);
         rxbyteisaligned_out                : out slv(0 downto 0);
         rxbyterealign_out                  : out slv(0 downto 0);
         rxclkcorcnt_out                    : out slv(1 downto 0);
         rxcommadet_out                     : out slv(0 downto 0);
         rxctrl0_out                        : out slv(15 downto 0);
         rxctrl1_out                        : out slv(15 downto 0);
         rxctrl2_out                        : out slv(7 downto 0);
         rxctrl3_out                        : out slv(7 downto 0);
         rxpmaresetdone_out                 : out slv(0 downto 0);
         txpmaresetdone_out                 : out slv(0 downto 0);
         txprgdivresetdone_out              : out slv(0 downto 0));
   end component;

   signal rxUsrClk2Int      : sl;
   signal rxUsrClkActiveInt : sl;
   signal txUsrClk2Int      : sl;
   signal txUsrClkActiveInt : sl;

   signal drpAddr : slv(8 downto 0);
   signal drpDi   : slv(15 downto 0);
   signal drpDo   : slv(15 downto 0);
   signal drpEn   : sl;
   signal drpWe   : sl;
   signal drpRdy  : sl;

   signal dummy0_6 : slv(5 downto 0);
   signal dummy1_14 : slv(13 downto 0);
   signal dummy2_14 : slv(13 downto 0);
   signal dummy3_6 : slv(5 downto 0);
   signal dummy4_1 : sl;
   signal dummy5_1 : sl;

begin

   rxUsrClk2 <= rxUsrClk2Int;
   txUsrClk2 <= txUsrClk2Int;

   U_RstSync_TX : entity work.RstSync
      generic map (
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '0',
         OUT_POLARITY_G => '1',
         OUT_REG_RST_G  => false)
      port map (
         clk      => txUsrClk2Int,       -- [in]
         asyncRst => txUsrClkActiveInt,  -- [in]
         syncRst  => txUsrClkRst);       -- [out]
   --
   U_RstSync_RX : entity work.RstSync
      generic map (
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '0',
         OUT_POLARITY_G => '1',
         OUT_REG_RST_G  => false)
      port map (
         clk      => rxUsrClk2Int,       -- [in]
         asyncRst => rxUsrClkActiveInt,  -- [in]
         syncRst  => rxUsrClkRst);       -- [out]

   -- Note: Has to be generated from aurora core in order to work properly
   U_PgpGthCore : PgpGthCore
      port map (
         gtwiz_userclk_tx_reset_in(0)          => txReset,
         gtwiz_userclk_tx_srcclk_out(0)        => txOutClk,
         gtwiz_userclk_tx_usrclk_out(0)        => txUsrClk,
         gtwiz_userclk_tx_usrclk2_out(0)       => txUsrClk2Int,
         gtwiz_userclk_tx_active_out(0)        => txUsrClkActiveInt,
         gtwiz_userclk_rx_reset_in(0)          => rxReset,
         gtwiz_userclk_rx_srcclk_out(0)        => rxOutClk,
         gtwiz_userclk_rx_usrclk_out(0)        => rxUsrClk,
         gtwiz_userclk_rx_usrclk2_out(0)       => rxUsrClk2Int,
         gtwiz_userclk_rx_active_out(0)        => rxUsrClkActiveInt,
         gtwiz_reset_clk_freerun_in(0)         => stableClk,
         gtwiz_reset_all_in(0)                 => stableRst,
         gtwiz_reset_tx_pll_and_datapath_in(0) => '0',
         gtwiz_reset_tx_datapath_in(0)         => '0',
         gtwiz_reset_rx_pll_and_datapath_in(0) => '0',
         gtwiz_reset_rx_datapath_in(0)         => rxReset,
         gtwiz_reset_rx_cdr_stable_out         => open,
         gtwiz_reset_tx_done_out(0)            => txResetDone,
         gtwiz_reset_rx_done_out(0)            => rxResetDone,
         gtwiz_userdata_tx_in                  => txData,
         gtwiz_userdata_rx_out                 => rxData,
         drpclk_in(0)                          => stableClk,
         drpaddr_in                            => drpAddr,
         drpdi_in                              => drpDi,
         drpen_in(0)                           => drpEn,
         drpwe_in(0)                           => drpWe,
         drpdo_out                             => drpDo,
         drprdy_out(0)                         => drpRdy,
         gthrxn_in(0)                          => gtRxN,
         gthrxp_in(0)                          => gtRxP,
         gtrefclk0_in(0)                       => gtRefClk,
         loopback_in                           => loopback,
         rxbufreset_in(0)                      => '0',
         rx8b10ben_in(0)                       => '1',
         rxcommadeten_in(0)                    => '1',
         rxmcommaalignen_in(0)                 => '1',
         rxpcommaalignen_in(0)                 => '1',
         rxpolarity_in(0)                      => rxPolarity,
         txpolarity_in(0)                      => txPolarity,         
         tx8b10ben_in(0)                       => '1',
         txctrl0_in                            => X"0000",
         txctrl1_in                            => X"0000",
         txctrl2_in(1 downto 0)                => txDataK,
         txctrl2_in(7 downto 2)                => dummy0_6,
         gthtxn_out(0)                         => gtTxN,
         gthtxp_out(0)                         => gtTxP,
         rxbyteisaligned_out                   => open,
         rxbyterealign_out                     => open,
         rxcommadet_out                        => open,
         rxctrl0_out(1 downto 0)               => rxDataK,
         rxctrl0_out(15 downto 2)              => dummy1_14,
         rxctrl1_out(1 downto 0)               => rxDispErr,
         rxctrl1_out(15 downto 2)              => dummy2_14,
         rxctrl2_out                           => open,
         rxctrl3_out(1 downto 0)               => rxDecErr,
         rxctrl3_out(7 downto 2)               => dummy3_6,
         rxpmaresetdone_out(0)                 => dummy4_1,
         txpmaresetdone_out(0)                 => dummy5_1);

   U_AxiLiteToDrp_1 : entity work.AxiLiteToDrp
      generic map (
         TPD_G            => TPD_G,
         AXI_ERROR_RESP_G => AXIL_ERROR_RESP_G,
         COMMON_CLK_G     => false,
         EN_ARBITRATION_G => false,
         ADDR_WIDTH_G     => 9,
         DATA_WIDTH_G     => 16)
      port map (
         axilClk         => axilClk,          -- [in]
         axilRst         => axilRst,          -- [in]
         axilReadMaster  => axilReadMaster,   -- [in]
         axilReadSlave   => axilReadSlave,    -- [out]
         axilWriteMaster => axilWriteMaster,  -- [in]
         axilWriteSlave  => axilWriteSlave,   -- [out]
         drpClk          => stableClk,        -- [in]
         drpRst          => stableRst,        -- [in]
         drpReq          => open,             -- [out]
         drpRdy          => drpRdy,           -- [in]
         drpEn           => drpEn,            -- [out]
         drpWe           => drpWe,            -- [out]
         drpUsrRst       => open,             -- [out]
         drpAddr         => drpAddr,          -- [out]
         drpDi           => drpDi,            -- [out]
         drpDo           => drpDo);           -- [in]
end architecture mapping;
