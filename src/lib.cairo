use core::clone::Clone;
use core::array::ArrayTrait;
use core::debug::PrintTrait;
use alexandria_math::BitShift;

use core::traits::Into;
use core::traits::DivRem;

use alexandria_encoding::base64::Base64UrlEncoder;
use alexandria_data_structures::array_ext::ArrayTraitExt;
trait BytesBeReversed {
    fn bytes_be_reversed(self: felt252) -> Array<u8>;
}

impl BytesBeReversedImpl of BytesBeReversed {
    fn bytes_be_reversed(self: felt252) -> Array<u8> {
        let mut new_arr = array![];

        let mut num: u256 = self.into();
        loop {
            if num == 0 {
                break;
            }
            let (quotient, remainder) = DivRem::div_rem(
                num, 256_u256.try_into().expect('Division by 0')
            );
            new_arr.append(remainder.try_into().unwrap());
            num = quotient;
        };
        loop {
            if new_arr.len() >= 32 {
                break;
            }
            new_arr.append(0_u8);
        };
        new_arr
    }
}

fn main() {
    let bytes = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5_felt252.bytes_be_reversed();
    let mut bytes2 = bytes.clone();
    loop {
        let byte = bytes2.pop_front();
        match byte {
            Option::Some(b) => {
                // PrintTrait::print(b);
            },
            Option::None => {
                break;
            }
        }
    };
    let mut challenge = Base64UrlEncoder::encode(bytes);
    // let mut challenge_2 = Base64UrlEncoder::encode();
    let challenge_len: usize = challenge.len();
    // challenge.append_all(ref challenge_2);
    challenge.len().print();
    '_______'.print();
    loop {
        let byte = challenge.pop_front();
        match byte {
            Option::Some(b) => {
                PrintTrait::print(b);
            },
            Option::None => {
                break;
            }
        }
    };
}

fn base64url_encode(mut bytes: Array<u8>) -> Array<u8> {
    let base64_chars = base64_chars();
    let mut result = array![];
    let mut p: usize = 0;
    let c = bytes.len() % 3;
    if c == 1 {
        p = 2;
        bytes.append(0_u8);
        bytes.append(0_u8);
    } else if c == 2 {
        p = 1;
        bytes.append(0_u8);
    }

    let mut i = 0;
    let bytes_len = bytes.len();
    loop {
        if i == bytes_len {
            break;
        }
        let mut n: u128 = BitShift::shl((*bytes[i]).into(), 16) 
            | BitShift::shl((*bytes[i + 1]).into(), 8) 
            | (*bytes[i + 2]).into();
        let e1: usize = (BitShift::shr(n, 18) & 63).try_into().unwrap();
        result.append(*base64_chars[e1]);
        let e2: usize = (BitShift::shr(n, 12) & 63).try_into().unwrap();
        result.append(*base64_chars[(e2)]);
        let e3: usize = (BitShift::shr(n, 6) & 63).try_into().unwrap();
        if i + 3 == bytes_len && p == 2 {
            result.append('=');
        } else {
            result.append(*base64_chars[e3]);
        }
        let e4: usize = (n & 63).try_into().unwrap();
        if i + 3 == bytes_len && p >= 1 {
            result.append('=');
        } else {
            result.append(*base64_chars[e4]);
        }
        i += 3;
    };
    result
}

#[test]
fn test_new_base64(){
    let bytes = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5_felt252.bytes_be_reversed();
    let old = Base64UrlEncoder::encode(bytes.clone());
    let new = base64url_encode(bytes);
    assert!(old == new, "expected equal");
    let bytes = 0x012345657889_felt252.bytes_be_reversed();
    let old = Base64UrlEncoder::encode(bytes.clone());
    let new = base64url_encode(bytes);
    assert!(old == new, "expected equal");
}

#[test]
fn test_only_old_base64(){
    let bytes = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5_felt252.bytes_be_reversed();
    let old = Base64UrlEncoder::encode(bytes);
}

#[test]
fn test_only_new_base64(){
    let bytes = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5_felt252.bytes_be_reversed();
    let new = base64url_encode(bytes);
}


fn base64_chars() -> Array<u8> {
    let mut result = array![
        'A',
        'B',
        'C',
        'D',
        'E',
        'F',
        'G',
        'H',
        'I',
        'J',
        'K',
        'L',
        'M',
        'N',
        'O',
        'P',
        'Q',
        'R',
        'S',
        'T',
        'U',
        'V',
        'W',
        'X',
        'Y',
        'Z',
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
        'g',
        'h',
        'i',
        'j',
        'k',
        'l',
        'm',
        'n',
        'o',
        'p',
        'q',
        'r',
        's',
        't',
        'u',
        'v',
        'w',
        'x',
        'y',
        'z',
        '0',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '-',
        '_'
    ];
    result
}

    

