def divs_rev():
    d = 16
    yield d
    for _ in range(41):
        d *= 64
        yield d

divs = list(divs_rev())
divs.reverse()

for d in divs:
    print(f"let c = (num / {d}).try_into().unwrap() & 63_u8;")
    print("result.append(*base64_chars[c.into()]);")