use core::option::OptionTrait;
use core::traits::TryInto;
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
    fn base64(self: felt252) -> Array<u8>;
}

impl BytesBeReversedImpl of BytesBeReversed {
    fn bytes_be_reversed(self: felt252) -> Array<u8> {
        let mut result = array![];

        let mut num: u256 = self.into();
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
        result
    }
    fn base64(self: felt252) -> Array<u8>{
        let mut result = array![];

        let mut num: u256 = self.into();
        let base64_chars = base64_chars(); 
        if num != 0 {
            let (quotient, remainder) = DivRem::div_rem(
                num, 65536_u256.try_into().expect('Division by 0')
            );
            let remainder: usize = remainder.try_into().unwrap();
            let r3: usize = (remainder / 1024) & 63;
            let r2: usize = (remainder / 16) & 63;
            let r1: usize = (remainder * 4) & 63;
            result.append(*base64_chars[r1]);
            result.append(*base64_chars[r2]);
            result.append(*base64_chars[r3]);
            num = quotient;
        }
        loop {
            if num == 0 {
                break;
            }
            let (quotient, remainder) = DivRem::div_rem(
                num, 16777216_u256.try_into().expect('Division by 0')
            );
            let remainder: usize = remainder.try_into().unwrap();
            let r4: usize = remainder / 262144;
            let r3: usize = (remainder / 4096) & 63;
            let r2: usize = (remainder / 64) & 63;
            let r1: usize = remainder & 63;
            result.append(*base64_chars[r1]);
            result.append(*base64_chars[r2]);
            result.append(*base64_chars[r3]);
            result.append(*base64_chars[r4]);
            num = quotient;
        };
        loop {
            if result.len() >= 43 {
                break;
            }
            result.append('A');
        };
        result = result.reverse();
        result.append('=');
        result
    }
}

fn assert_combined(value: felt252){
    let bytes = value.bytes_be_reversed().reverse();
    let mut old = Base64UrlEncoder::encode(bytes.clone());
    let mut combined = value.base64();
    assert!(old == combined, "expected equal");
}

#[test]
fn test_many_combined(){
    assert_combined(0);
    assert_combined(1);
    assert_combined(15);
    assert_combined(16);
    assert_combined(17);
    assert_combined(63);
    assert_combined(64);
    assert_combined(65);
    assert_combined(0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5_felt252);
    assert_combined(0x017a7b7874ce525fd66dbeecd76221bcdf641ec6a04ffa4269e1e57f1dd801b7);
    assert_combined(0x009e8079ae1684cc447368fa163f568ece99274d7fa22118e8c43de39ec2f5ee);
    assert_combined(0x072ca3b8a7a43be93dade5db8e3a7b132f11d63b81da3482ea63646e9a16675f);
    assert_combined(0x0553b2adf00a529395dc4c8b55f738fe8b1ef48b07264cac6e523eebd364485b);
    assert_combined(0x0547fe2d2f919cd0edd1d5731ac6aabb0741dec2298019ca892bef40e1ca73e1);
    assert_combined(0x0670d5a64981925bbc53cea9379ec96e1c1e2213d0a33c613c29dea4729f96d8);
    assert_combined(0x024f2047262e7c1a83caaf75aa6165ecb3d3616766b036373de77b57bc161283);
    assert_combined(0x051f991713090c55205c278cc8169fe559ddc008757647da0c5f687a4fc9a40d);
    assert_combined(0x03bfddb7590e4661c144114c0283453e20ba61816887fb0cc4a6aeb7b69abd3a);
    assert_combined(0x027809bba4ea61759535391721508a6c00bd407c189bfa4b09cc792e1d599949);
}


#[test]
fn test_only_old_base64(){
    let bytes = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5_felt252.bytes_be_reversed();
    let old = Base64UrlEncoder::encode(bytes);
}

#[test]
fn test_only_bytes(){
    let bytes = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5_felt252.bytes_be_reversed();
}

#[test]
fn test_only_combined(){
    let bytes = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5_felt252.base64();
}

#[test]
fn test_only_new_combined(){
    let bytes = base64new(0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5_felt252);
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

    
fn base64new(val: felt252) -> Array<u8>{
    let mut result = array![];

    let mut num: u256 = val.into();
    let base64_chars = base64_chars(); 

    let c = (num / 1809251394333065553493296640760748560207343510400633813116524750123642650624) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 28269553036454149273332760011886696253239742350009903329945699220681916416) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 441711766194596082395824375185729628956870974218904739530401550323154944) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 6901746346790563787434755862277025452451108972170386555162524223799296) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 107839786668602559178668060348078522694548577690162289924414440996864) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 1684996666696914987166688442938726917102321526408785780068975640576) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 26328072917139296674479506920917608079723773850137277813577744384) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 411376139330301510538742295639337626245683966408394965837152256) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 6427752177035961102167848369364650410088811975131171341205504) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 100433627766186892221372630771322662657637687111424552206336) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 1569275433846670190958947355801916604025588861116008628224) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 24519928653854221733733552434404946937899825954937634816) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 383123885216472214589586756787577295904684780545900544) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 5986310706507378352962293074805895248510699696029696) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 93536104789177786765035829293842113257979682750464) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 1461501637330902918203684832716283019655932542976) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 22835963083295358096932575511191922182123945984) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 356811923176489970264571492362373784095686656) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 5575186299632655785383929568162090376495104) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 87112285931760246646623899502532662132736) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 1361129467683753853853498429727072845824) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 21267647932558653966460912964485513216) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 332306998946228968225951765070086144) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 5192296858534827628530496329220096) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 81129638414606681695789005144064) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 1267650600228229401496703205376) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 19807040628566084398385987584) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 309485009821345068724781056) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 4835703278458516698824704) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 75557863725914323419136) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 1180591620717411303424) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 18446744073709551616) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 288230376151711744) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 4503599627370496) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 70368744177664) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 1099511627776) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 17179869184) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 268435456) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 4194304) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 65536) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 1024) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num / 16) & 63;
    result.append(*base64_chars[c.try_into().unwrap()]);
    let c = (num & 15) * 4;
    result.append(*base64_chars[c.try_into().unwrap()]);

    result.append('=');
    result
}


fn util(){
    let felt = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5_felt252;
    // let felt = 17;
    let bytes = felt.bytes_be_reversed().reverse();
    let mut old = Base64UrlEncoder::encode(bytes.clone());
    let new = base64url_experiment(bytes);
    let mut combined = base64new(felt);
    // assert!(old == new, "expected equal");
    // assert!(old == combined, "expected equal");
    old.len().print();
    combined.len().print();
    loop {
        let byte = old.pop_front();
        match byte {
            Option::Some(b) => {
                PrintTrait::print(b);
            },
            Option::None => {
                break;
            }
        }
    };
    '_______'.print();
    loop {
        let byte = combined.pop_front();
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