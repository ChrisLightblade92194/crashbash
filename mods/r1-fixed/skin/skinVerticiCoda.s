# M3-V3 (Task B4): seguito di skin_anteprima_coda (skin/skinCoda.s), nel frame di skin_anteprima.
# Sede: EXE, blocco _SsSndSetVol (0x8003840c-0x8003848c, 128 byte, riserva di V3 provata nel Task 0.5).
# - skin_vertici_coda: dopo la lettura riuscita del record in 0x800a8000 esegue skin_scrivi($s0),
#   skin_celle($s0, $s1), skin_vertici_podio($s0) e variante_mostrata[$s0 − 1] = $s1.
# - skin_vertici_svuota: rimette a zero skin_tentativi e il settore del record (sempre a zero alla Character
#   Select, Task 0.3), anche dopo una lettura fallita; poi «j skin_anteprima_svuota».
# - skin_vertici_mesh: scostamento nel .mdl del podio della mesh di ogni personaggio 1-8, 0x58 + 52 × mesh
#   (celle_podio.MESH_PERSONAGGI).
.set noreorder
.set noat

.global skin_vertici_coda
skin_vertici_coda:
    jal   skin_scrivi
    move  $a0, $s0
    move  $a0, $s0
    jal   skin_celle
    move  $a1, $s1
    jal   skin_vertici_podio
    move  $a0, $s0
    lui   $t0, %hi(variante_mostrata - 1)
    addu  $t0, $t0, $s0
    sb    $s1, %lo(variante_mostrata - 1)($t0)
.global skin_vertici_svuota
skin_vertici_svuota:
    lui   $t1, %hi(skin_tentativi)
    sb    $zero, %lo(skin_tentativi)($t1)
    lui   $t0, 0x800a
    ori   $t0, $t0, 0x8000
    addiu $t1, $t0, 2048
skin_vertici_azzera:
    addiu $t0, $t0, 4
    bne   $t0, $t1, skin_vertici_azzera
    sw    $zero, -4($t0)
    j     skin_anteprima_svuota
    nop

.global skin_vertici_mesh
skin_vertici_mesh:
    .half 0x58 + 52 * 15, 0x58 + 52 * 14, 0x58 + 52 * 16, 0x58 + 52 * 17
    .half 0x58 + 52 * 20, 0x58 + 52 * 21, 0x58 + 52 * 18, 0x58 + 52 * 19
