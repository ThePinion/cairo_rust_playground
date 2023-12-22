import random
def imports() -> list[str]:
    return [
        "use core::debug::PrintTrait;",
        "use core::clone::Clone;",
        "use core::array::ArrayTrait;",
        "use alexandria_encoding::base64::{Base64UrlEncoder, Base64UrlDecoder, Base64Decoder, Base64Encoder}; ",
        ""
    ]

def cairo_arr(arr: list[int]) -> list[str]:
    output = ["let value: Array<u8> = {", "\tlet mut value = ArrayTrait::new();"]
    for a in arr:
        output.append(f"\tvalue.append({a});")
    output.append("\tvalue")
    output.append("};")
    return output

def cairo_assertion() -> list[str]:
    return [
        "let encoded = Base64UrlEncoder::encode(value.clone());",
        "let decoded = Base64UrlDecoder::decode(encoded);",
        "assert(decoded == value, 'Encoding roundtrip is identity');",
        "let encoded = Base64Encoder::encode(value.clone());",
        "let decoded = Base64Decoder::decode(encoded);",
        "assert(decoded == value, 'Encoding roundtrip is identity');"
    ]

def cairo_test(len: int, id: int) -> list[str]:
    arr = [random.randint(0, 255) for _ in range(len)]
    name = f"test{id}_l{len}_" + "_".join(map(lambda x: str(x), arr))
    return [
        "#[test]", 
        "#[available_gas(200000000000000)]", 
        f"fn {name}() {{"
    ] + ["\t" + s for s in cairo_arr(arr)] + ["\t" + s for s in cairo_assertion()] + ["}"]

def gen_file() -> str:
    output = imports()
    id = 0
    for _ in range(1000):
        output += cairo_test(random.randint(0, 1000), id)
        output += [""]
        id += 1
    return "\n".join(output)

if __name__ == "__main__":
    print(gen_file())

