# M3-L15: Loader_QueueCharacterModels, chiamata per la tabella secondary (0x800939ac, voce 991): jal FUN_800129d0
# sostituita da jal skin_accoda; il delay slot (move a1, s5) resta.
.set noreorder
jal   skin_accoda
