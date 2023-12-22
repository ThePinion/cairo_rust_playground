use primitive_types::U256;
use starknet::{macros::felt, core::types::FieldElement, signers::SigningKey};

struct Bits {
    value: Vec<bool>,
    chunk_size: usize
}

impl Bits {
    fn new(value: &[u8], take: usize) -> Bits {
        let mut result = Vec::new();
        for byte in value {
            for i in (8-take)..8 {
                let val = (byte >> (7 - i)) & 1 == 1;
                result.push(val);
            }
        }
        Bits {
            value: result,
            chunk_size: take
        }
    }
    fn print(&self) {
        for i in 0..self.value.len() {
            print!("{}", if self.value[i] { 1 } else { 0 });
            if (i+1) % self.chunk_size == 0 {
                print!(",");
            } else {
                print!(" ")
            }
        }
        println!();
    }
}

fn felt_to_base64(felt: FieldElement) -> Vec<u8> {
    let felt = felt * FieldElement::from(1_u32);
    let mut num: U256 = U256::from_dec_str(&felt.to_string()).unwrap();
    let mut result = Vec::new();
    if num != 0.into() {
        let reminder = num % 16;
        let quotient = num / 16;
        let remainder: u8 = reminder.try_into().unwrap();
        result.push(remainder * 4);
        num = quotient;
    }
    while num != 0.into() {
        let reminder = num % 64;
        let quotient = num / 64;
        let remainder: u8 = reminder.try_into().unwrap();
        result.push(remainder);
        num = quotient;
    }
    while result.len() < 43 {
        result.push(0);
    }
    result.reverse();
    result.push(0);
    result
}

fn base_64_bits(value: &[u8]) -> Bits {
    use base64::{engine::general_purpose::URL_SAFE, Engine as _};
    let encoded = URL_SAFE.encode(value);
    let mut result = Vec::new();
    println!("{}", encoded);
    for e in encoded.chars() {
        match URL_SAFE.decode(format!("AAA{e}")) {
            Ok(v) => {
                if v.len() == 3 {
                    result.push(v[2])
                } else {
                    result.push(0)
                }
            },
            Err(_) => ()
        };
    }
    Bits::new(&result, 6)
}

fn main() {
    for _ in 0..10 {
        println!("{:?}", SigningKey::from_random().secret_scalar());
    }
    // let felt = felt!("0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5");
    // let bytes = &felt.to_bytes_be();
    // let be_bits = Bits::new(bytes, 8);
    // let base64_bits = Bits::new(&felt_to_base64(felt), 6);
    // let base64_real_bits = base_64_bits(bytes);
    // be_bits.print();
    // base64_bits.print();
    // base64_real_bits.print();
}

#[cfg(test)]
fn test_felt(felt: FieldElement) {
    let bytes = &felt.to_bytes_be();
    let base64_bits = Bits::new(&felt_to_base64(felt), 6);
    let base64_real_bits = base_64_bits(bytes);
    assert_eq!(base64_bits.value, base64_real_bits.value);
}

#[test]
fn test_many() {
    for _ in 0..10000 {
        test_felt(SigningKey::from_random().secret_scalar());
    }
}
