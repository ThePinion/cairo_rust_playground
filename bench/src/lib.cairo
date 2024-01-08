use core::clone::Clone;
use alexandria_math::BitShift;
use alexandria_data_structures::array_ext::ArrayTraitExt;
use alexandria_encoding::base64::Base64Encoder;
use core::debug::PrintTrait;
use core::testing;
use core::gas;
const U6_MAX: u128 = 0x3F;

fn bytes_be(val: felt252) -> Array<u8> {
    let mut result = array![];

    let mut num: u256 = val.into();
    loop {
        if num == 0 {
            break;
        }
        let (quotient, remainder) = DivRem::div_rem(
            num, 256_u256.try_into().expect('Division by 0')
        );
        result.append(remainder.try_into().unwrap());
        num = quotient;
    };
    loop {
        if result.len() >= 32 {
            break;
        }
        result.append(0_u8);
    };
    result = result.reverse();
    result
}

const TWO_TO_248: felt252 = 452312848583266388373324160190187140051835877600158453279131187530910662656;

fn bytes_be_rev(val: felt252) -> Array<u8> {
    let mut result = array![];

    let mut num: u256 = val.into();
    let mut divider: u256 = TWO_TO_248.into();
    loop {
        if num == 0 {
            break;
        }
        if divider == 0 {
            break;
        }
        let (quotient, remainder) = DivRem::div_rem(num, divider.try_into().unwrap());
        result.append(quotient.try_into().unwrap());
        num = remainder;
        divider = divider / 256_u256;
    };
    loop {
        if result.len() >= 32 {
            break;
        }
        result.append(0_u8);
    };
    result
}


#[test]
#[available_gas(200000000)]
fn correctness_test() {
    let data: felt252 = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5;
    assert(bytes_be(data) == bytes_be_rev(data), '');
}

#[test]
#[available_gas(200000000)]
fn bench1() {
    let data: felt252 = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5;
    let initial = testing::get_available_gas();
    gas::withdraw_gas().unwrap();
    bytes_be(data);
    let gas = (initial - testing::get_available_gas());
    'old'.print();
    gas.print();
    'old'.print();
}

#[test]
#[available_gas(200000000)]
fn bench2() {
    let data: felt252 = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5;
    let initial = testing::get_available_gas();
    gas::withdraw_gas().unwrap();
    bytes_be_rev(data);
    let gas = (initial - testing::get_available_gas());
    'rev'.print();
    gas.print();
    'rev'.print();
}


