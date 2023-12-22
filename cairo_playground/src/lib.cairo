use alexandria_encoding::reversible::ReversibleBytes;
use alexandria_encoding::reversible::ReversibleBits;
use core::clone::Clone;
use core::array::ArrayTrait;
use core::debug::PrintTrait;

use core::traits::Into;
use core::traits::DivRem;

use alexandria_encoding::base64::Base64UrlEncoder;
use alexandria_data_structures::array_ext::ArrayTraitExt;
trait BytesBeReversed {
    fn bytes_be_reversed(self: felt252) -> Array<u8>;
    fn base64_reversed(self: felt252) -> Array<u8>;
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
    fn base64_reversed(self: felt252) -> Array<u8>{
        let mut new_arr = array![];

        let mut num: u256 = self.into().reverse_bytes();
        let base64_chars = base64_chars(); 
        loop {
            if num == 0 {
                break;
            }
            let (quotient, remainder) = DivRem::div_rem(
                num, 64_u256.try_into().expect('Division by 0')
            );
            let remainder: u8 = remainder.try_into().unwrap();
            let remainder = remainder;
            let encoded = *base64_chars[remainder.into()];
            new_arr.append(encoded);
            num = quotient;
        };
        loop {
            if new_arr.len() >= 44 {
                break;
            }
            new_arr.append('=');
        };
        new_arr
    }
}

#[test]
fn test_new_base64(){
    let felt = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5_felt252;
    let bytes = felt.bytes_be_reversed().reverse();
    let mut old = Base64UrlEncoder::encode(bytes.clone());
    let new = base64url_experiment(bytes);
    let mut combined = felt.base64_reversed();
    // assert!(old == new, "expected equal");
    // assert!(old == combined, "expected equal");
    // loop {
    //     let byte = old.pop_front();
    //     match byte {
    //         Option::Some(b) => {
    //             PrintTrait::print(b);
    //         },
    //         Option::None => {
    //             break;
    //         }
    //     }
    // };
    // '_______'.print();
    // loop {
    //     let byte = combined.pop_front();
    //     match byte {
    //         Option::Some(b) => {
    //             PrintTrait::print(b);
    //         },
    //         Option::None => {
    //             break;
    //         }
    //     }
    // };
}

#[test]
fn test_only_old_base64(){
    let bytes = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5_felt252.bytes_be_reversed();
    let old = Base64UrlEncoder::encode(bytes);
}

#[test]
fn only_bytes(){
    let bytes = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5_felt252.bytes_be_reversed();
}


#[test]
fn test_only_new_base64(){
    let bytes = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5_felt252.bytes_be_reversed();
    let new = base64url_encode(bytes);
}

#[test]
fn test_only_experiment_base64(){
    let bytes = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5_felt252.bytes_be_reversed();
    let new = base64url_experiment(bytes);
}

fn base64url_encode(mut bytes: Array<u8>) -> Array<u8> {
    let base64_chars = base64_chars();
    let mut result = array![];
    let mut p: u8 = 0;
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
    let last_iteration = bytes_len - 3;
    loop {
        if i == bytes_len {
            break;
        }
        let n: u32 = (*bytes[i]).into() * 65536_u32
            | (*bytes[i + 1]).into() * 256_u32
            | (*bytes[i + 2]).into();
        let e1: usize = ((n / 262144) & 63).try_into().unwrap();
        let e2: usize = ((n / 4096) & 63).try_into().unwrap();
        let e3: usize = ((n / 64) & 63).try_into().unwrap();
        let e4: usize = (n & 63).try_into().unwrap();
        result.append(*base64_chars[e1]);
        result.append(*base64_chars[(e2)]);
        if i == last_iteration {
            if p == 2 {
                result.append('=');
                result.append('=');
            } else if p == 1 {
                result.append(*base64_chars[e3]);
                result.append('=');
            } else {
                result.append(*base64_chars[e3]);
                result.append(*base64_chars[e4]);
            }
        } else {
            result.append(*base64_chars[e3]);
            result.append(*base64_chars[e4]);
        }
        i += 3;
    };
    result
}

fn base64url_experiment(mut bytes: Array<u8>) -> Array<u8> {
    let base64_chars = base64_chars();
    let mut result = array![];
    let mut p: u8 = 0;
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
    let last_iteration = bytes_len - 3;
    loop {
        if i == bytes_len {
            break;
        }
        let n1: u8 = (*bytes[i]).into();
        let n2: u8 = (*bytes[i + 1]).into();
        let n3: u8 = (*bytes[i + 2]).into();

        let e1: usize  = ((n1 / 4) & 63).try_into().unwrap();
        let e2: usize  = ((((n1 & 3) * 16 ) | (n2 / 16)) & 63).try_into().unwrap();
        let e3: usize  = ((((n2 & 15) * 4) | (n3 / 64)) & 63).try_into().unwrap();
        let e4: usize  = (n3 & 63).try_into().unwrap();

        result.append(*base64_chars[e1]);
        result.append(*base64_chars[(e2)]);
        if i == last_iteration {
            if p == 2 {
                result.append('=');
                result.append('=');
            } else if p == 1 {
                result.append(*base64_chars[e3]);
                result.append('=');
            } else {
                result.append(*base64_chars[e3]);
                result.append(*base64_chars[e4]);
            }
        } else {
            result.append(*base64_chars[e3]);
            result.append(*base64_chars[e4]);
        }
        i += 3;
    };
    result
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

    

