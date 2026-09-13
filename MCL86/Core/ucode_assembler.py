#!/usr/bin/env python3
"""
Microcode assembler for MCL86 / MCL86jr.

Source format (Microcode_MCL86.txt):
  Each microcode word is a triplet of `p` lines:
    p 00 00000 00001 AAAA   # 12-bit ROM address (in hex)
    p 01 00000 00001 HHHH   # upper 16 bits of 32-bit word
    p 01 00000 00001 LLLL   # lower 16 bits of 32-bit word
  The full word at ROM[AAAA] = HHHH:LLLL.

  `d AAAA` lines fill subsequent un-targeted entries (current pointer).
  `#` lines are comments. Anything else is ignored.

Output formats:
  - .coe  Xilinx COE format (memory_initialization_vector hex words)
  - .mem  Verilog $readmemh (one hex word per line)
"""
import sys, re, argparse

ROM_SIZE = 4096

def parse_text(path):
    rom = [0] * ROM_SIZE
    pending_addr = None
    pending_high = None
    cur_addr = 0
    with open(path) as f:
        for lineno, raw in enumerate(f, 1):
            s = raw.strip()
            if not s or s.startswith('#') or s.startswith('//') or s.startswith('--'):
                continue
            tok = s.split()
            if tok[0] == 'd' and len(tok) >= 2:
                # default address pointer
                cur_addr = int(tok[1], 16)
                continue
            if tok[0] == 'p' and len(tok) >= 5:
                tag = tok[1]
                # tok[3] is the channel/target. 00001 = microcode ROM; 00010 =
                # simulator control register (Stop CPU / Set trigger / Start CPU).
                # We only assemble the 00001 microcode stream.
                channel = tok[3]
                value = int(tok[-1], 16)
                if channel != '00001':
                    # Reset any pending p-record state and skip.
                    pending_addr = None
                    pending_high = None
                    continue
                if tag == '00':
                    pending_addr = value & 0xFFF
                    pending_high = None
                elif tag == '01':
                    if pending_high is None:
                        pending_high = value & 0xFFFF
                    else:
                        word = (pending_high << 16) | (value & 0xFFFF)
                        addr = pending_addr if pending_addr is not None else cur_addr
                        rom[addr] = word
                        cur_addr = addr + 1
                        pending_addr = None
                        pending_high = None
                continue
    return rom

def write_coe(rom, path):
    with open(path, 'w') as f:
        f.write('memory_initialization_radix=16;\n')
        f.write('memory_initialization_vector=')
        words = ['{:08x}'.format(w) for w in rom]
        f.write(' '.join(words))
        f.write(';\n')

def write_mem(rom, path):
    with open(path, 'w') as f:
        for w in rom:
            f.write('{:08x}\n'.format(w))

def parse_coe(path):
    """Parse a .coe file into a 4096-word list."""
    with open(path) as f:
        content = f.read()
    # Find the memory_initialization_vector= section if present, else treat the
    # whole file as a sequence of hex words.
    m = re.search(r'memory_initialization_vector\s*=', content)
    if m:
        j = content.rfind(';')
        if j < m.end(): j = len(content)
        vec = content[m.end():j]
    else:
        # Strip COE header lines like "memory_initialization_radix=16;" and
        # comment lines, keep the rest as the hex stream.
        vec = re.sub(r'memory_initialization_radix\s*=\s*\d+\s*;', '', content)
        vec = re.sub(r';\s*$', '', vec.strip())
    parts = re.split(r'[\s,]+', vec.strip())
    rom = [0] * ROM_SIZE
    for k, p in enumerate(parts):
        if not p: continue
        if k >= ROM_SIZE: break
        rom[k] = int(p, 16)
    return rom

def cmd_assemble(args):
    rom = parse_text(args.text)
    if args.coe:
        write_coe(rom, args.coe)
    if args.mem:
        write_mem(rom, args.mem)
    if args.print:
        for k, w in enumerate(rom):
            if w: print(f'{k:03X} {w:08X}')

def cmd_match(args):
    """Try to identify which binary .coe the text source produces."""
    rom_text = parse_text(args.text)
    candidates = args.coes
    print(f'Source: {args.text}')
    print(f'  non-zero words: {sum(1 for w in rom_text if w)}')
    print()
    for c in candidates:
        try:
            rom_bin = parse_coe(c)
        except Exception as e:
            print(f'{c}: parse error: {e}')
            continue
        diffs = sum(1 for a, b in zip(rom_text, rom_bin) if a != b)
        first = next(((k, a, b) for k, (a, b) in enumerate(zip(rom_text, rom_bin)) if a != b), None)
        print(f'{c}:')
        print(f'  match: {ROM_SIZE - diffs}/{ROM_SIZE} ({100*(ROM_SIZE-diffs)/ROM_SIZE:.2f}%)')
        if first is not None:
            k, a, b = first
            print(f'  first diff at 0x{k:03X}: text={a:08X} bin={b:08X}')

def cmd_diff(args):
    """Show all words where text != binary."""
    rom_text = parse_text(args.text)
    rom_bin = parse_coe(args.coe)
    n = 0
    for k in range(ROM_SIZE):
        if rom_text[k] != rom_bin[k]:
            n += 1
            if n <= args.limit:
                print(f'{k:03X} text={rom_text[k]:08X} bin={rom_bin[k]:08X}')
    print(f'... {n} differences total' if n > args.limit else f'{n} differences total')

if __name__ == '__main__':
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest='cmd')

    pa = sub.add_parser('assemble', help='text -> coe/mem')
    pa.add_argument('text')
    pa.add_argument('--coe', help='output .coe file')
    pa.add_argument('--mem', help='output .mem file (verilog $readmemh)')
    pa.add_argument('--print', action='store_true')
    pa.set_defaults(func=cmd_assemble)

    pm = sub.add_parser('match', help='which .coe matches the text source?')
    pm.add_argument('text')
    pm.add_argument('coes', nargs='+')
    pm.set_defaults(func=cmd_match)

    pd = sub.add_parser('diff', help='show differences between text and a .coe')
    pd.add_argument('text')
    pd.add_argument('coe')
    pd.add_argument('--limit', type=int, default=200)
    pd.set_defaults(func=cmd_diff)

    args = p.parse_args()
    if not args.cmd:
        p.print_help()
        sys.exit(1)
    args.func(args)
