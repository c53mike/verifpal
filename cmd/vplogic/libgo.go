/* SPDX-FileCopyrightText: © 2019-2020 Nadim Kobeissi <nadim@symbolic.software>
 * SPDX-License-Identifier: GPL-3.0-only */
// 00000000000000000000000000000000

package vplogic

import "strings"

var libgo = strings.Join([]string{
	"/* SPDX-FileCopyrightText: © 2019-2020 Nadim Kobeissi <nadim@symbolic.software>",
	" * SPDX-License-Identifier: GPL-3.0-only */",
	"",
	"// Implementation Version: 0.0.1",
	"",
	"/* ---------------------------------------------------------------- *",
	" * PARAMETERS                                                       *",
	" * ---------------------------------------------------------------- */",
	"",
	"// nolint:deadcode,unused",
	"package main",
	"",
	"import (",
	"\t\"crypto/aes\"",
	"\t\"crypto/cipher\"",
	"\t\"crypto/hmac\"",
	"\t\"crypto/rand\"",
	"\t\"crypto/sha256\"",
	"\t\"fmt\"",
	"\t\"io\"",
	"\t\"math/big\"",
	"\t\"strings\"",
	"",
	"\t\"golang.org/x/crypto/chacha20poly1305\"",
	"\t\"golang.org/x/crypto/curve25519\"",
	"\t\"golang.org/x/crypto/ed25519\"",
	"\t\"golang.org/x/crypto/hkdf\"",
	"\t\"golang.org/x/crypto/scrypt\"",
	")",
	"",
	"/* ---------------------------------------------------------------- *",
	" * ELLIPTIC CURVE CRYPTOGRAPHY                                      *",
	" * ---------------------------------------------------------------- */",
	"",
	"func x25519DhFromEd25519PublicKey(privateKey []byte, publicKey []byte) ([]byte, error) {",
	"\treturn curve25519.X25519(privateKey, publicKey)",
	"}",
	"",
	"func ed25519Gen() ([]byte, []byte, error) {",
	"\tpublicKey, privateKey, err := ed25519.GenerateKey(rand.Reader)",
	"\tif err != nil {",
	"\t\treturn publicKey, privateKey, err",
	"\t}",
	"\treturn privateKey, publicKey, nil",
	"}",
	"",
	"func ed25519PublicKeyToCurve25519(pk ed25519.PublicKey) []byte {",
	"\t/* SPDX-PackageCopyrightText: Copyright 2019 Google LLC",
	"\t * SPDX-License-Identifier: BSD-3-Clause */",
	"\tvar curve25519P, _ = new(big.Int).SetString(strings.Join([]string{",
	"\t\t\"578960446186580977117854925043439539266\",",
	"\t\t\"34992332820282019728792003956564819949\",",
	"\t}, \"\"), 10)",
	"\tbigEndianY := make([]byte, ed25519.PublicKeySize)",
	"\tfor i, b := range pk {",
	"\t\tbigEndianY[ed25519.PublicKeySize-i-1] = b",
	"\t}",
	"\tbigEndianY[0] &= 127",
	"\ty := new(big.Int).SetBytes(bigEndianY)",
	"\tdenom := big.NewInt(1)",
	"\tdenom.ModInverse(denom.Sub(denom, y), curve25519P)",
	"\tu := y.Mul(y.Add(y, big.NewInt(1)), denom)",
	"\tu.Mod(u, curve25519P)",
	"\tout := make([]byte, 32)",
	"\tuBytes := u.Bytes()",
	"\tfor i, b := range uBytes {",
	"\t\tout[len(uBytes)-i-1] = b",
	"\t}",
	"\treturn out",
	"}",
	"",
	"/* ---------------------------------------------------------------- *",
	" * PRIMITIVES                                                       *",
	" * ---------------------------------------------------------------- */",
	"",
	"func assert(a []byte, b []byte) bool {",
	"\treturn hmac.Equal(a, b)",
	"}",
	"",
	"func concat(a ...[]byte) []byte {",
	"\tb := []byte{}",
	"\tfor _, aa := range a {",
	"\t\tb = append(b, aa...)",
	"\t}",
	"\treturn b",
	"}",
	"",
	"func split2(b []byte) ([]byte, []byte) {",
	"\ta1 := b[00:32]",
	"\ta2 := b[32:64]",
	"\treturn a1, a2",
	"}",
	"",
	"func split3(b []byte) ([]byte, []byte, []byte) {",
	"\ta1 := b[00:32]",
	"\ta2 := b[32:64]",
	"\ta3 := b[64:96]",
	"\treturn a1, a2, a3",
	"}",
	"",
	"func split4(b []byte) ([]byte, []byte, []byte, []byte) {",
	"\ta1 := b[00:32]",
	"\ta2 := b[32:64]",
	"\ta3 := b[64:96]",
	"\ta4 := b[96:128]",
	"\treturn a1, a2, a3, a4",
	"}",
	"",
	"func split5(b []byte) ([]byte, []byte, []byte, []byte, []byte) {",
	"\ta1 := b[00:32]",
	"\ta2 := b[32:64]",
	"\ta3 := b[64:96]",
	"\ta4 := b[96:128]",
	"\ta5 := b[128:160]",
	"\treturn a1, a2, a3, a4, a5",
	"}",
	"",
	"func hash(a ...[]byte) []byte {",
	"\tb := []byte{}",
	"\tfor _, aa := range a {",
	"\t\tb = append(b, aa...)",
	"\t}",
	"\th := sha256.Sum256(b)",
	"\treturn h[:]",
	"}",
	"",
	"func mac(k []byte, message []byte) ([]byte, error) {",
	"\tmac := hmac.New(sha256.New, k)",
	"\t_, err := mac.Write(message)",
	"\treturn mac.Sum(nil), err",
	"}",
	"",
	"func hkdf1(ck []byte, ikm []byte) ([]byte, error) {",
	"\tk1 := make([]byte, 32)",
	"\toutput := hkdf.New(sha256.New, ikm, ck, []byte{})",
	"\t_, err := io.ReadFull(output, k1)",
	"\treturn k1, err",
	"}",
	"",
	"func hkdf2(ck []byte, ikm []byte) ([]byte, []byte, error) {",
	"\tk1 := make([]byte, 32)",
	"\tk2 := make([]byte, 32)",
	"\toutput := hkdf.New(sha256.New, ikm, ck, []byte{})",
	"\t_, err := io.ReadFull(output, k1)",
	"\tif err != nil {",
	"\t\treturn []byte{}, []byte{}, err",
	"\t}",
	"\t_, err = io.ReadFull(output, k2)",
	"\treturn k1, k2, err",
	"}",
	"",
	"func hkdf3(ck []byte, ikm []byte) ([]byte, []byte, []byte, error) {",
	"\tk1 := make([]byte, 32)",
	"\tk2 := make([]byte, 32)",
	"\tk3 := make([]byte, 32)",
	"\toutput := hkdf.New(sha256.New, ikm, ck, []byte{})",
	"\t_, err := io.ReadFull(output, k1)",
	"\tif err != nil {",
	"\t\treturn []byte{}, []byte{}, []byte{}, err",
	"\t}",
	"\t_, err = io.ReadFull(output, k2)",
	"\tif err != nil {",
	"\t\treturn []byte{}, []byte{}, []byte{}, err",
	"\t}",
	"\t_, err = io.ReadFull(output, k3)",
	"\treturn k1, k2, k3, err",
	"}",
	"",
	"func hkdf4(ck []byte, ikm []byte) ([]byte, []byte, []byte, []byte, error) {",
	"\tk1 := make([]byte, 32)",
	"\tk2 := make([]byte, 32)",
	"\tk3 := make([]byte, 32)",
	"\tk4 := make([]byte, 32)",
	"\toutput := hkdf.New(sha256.New, ikm, ck, []byte{})",
	"\t_, err := io.ReadFull(output, k1)",
	"\tif err != nil {",
	"\t\treturn []byte{}, []byte{}, []byte{}, []byte{}, err",
	"\t}",
	"\t_, err = io.ReadFull(output, k2)",
	"\tif err != nil {",
	"\t\treturn []byte{}, []byte{}, []byte{}, []byte{}, err",
	"\t}",
	"\t_, err = io.ReadFull(output, k3)",
	"\tif err != nil {",
	"\t\treturn []byte{}, []byte{}, []byte{}, []byte{}, err",
	"\t}",
	"\t_, err = io.ReadFull(output, k4)",
	"\treturn k1, k2, k3, k4, err",
	"}",
	"",
	"func hkdf5(ck []byte, ikm []byte) ([]byte, []byte, []byte, []byte, []byte, error) {",
	"\tk1 := make([]byte, 32)",
	"\tk2 := make([]byte, 32)",
	"\tk3 := make([]byte, 32)",
	"\tk4 := make([]byte, 32)",
	"\tk5 := make([]byte, 32)",
	"\toutput := hkdf.New(sha256.New, ikm, ck, []byte{})",
	"\t_, err := io.ReadFull(output, k1)",
	"\tif err != nil {",
	"\t\treturn []byte{}, []byte{}, []byte{}, []byte{}, []byte{}, err",
	"\t}",
	"\t_, err = io.ReadFull(output, k2)",
	"\tif err != nil {",
	"\t\treturn []byte{}, []byte{}, []byte{}, []byte{}, []byte{}, err",
	"\t}",
	"\t_, err = io.ReadFull(output, k3)",
	"\tif err != nil {",
	"\t\treturn []byte{}, []byte{}, []byte{}, []byte{}, []byte{}, err",
	"\t}",
	"\t_, err = io.ReadFull(output, k4)",
	"\tif err != nil {",
	"\t\treturn []byte{}, []byte{}, []byte{}, []byte{}, []byte{}, err",
	"\t}",
	"\t_, err = io.ReadFull(output, k5)",
	"\treturn k1, k2, k3, k4, k5, err",
	"}",
	"",
	"func pwHash(a ...[]byte) ([]byte, error) {",
	"\th := hash(a...)",
	"\tsalt := make([]byte, 16)",
	"\t_, err := rand.Read(salt)",
	"\tif err != nil {",
	"\t\treturn []byte{}, err",
	"\t}",
	"\tdk, err := scrypt.Key(h, salt, 32768, 8, 1, 32)",
	"\treturn dk, err",
	"}",
	"",
	"func enc(k []byte, plaintext []byte) ([]byte, error) {",
	"\tblock, err := aes.NewCipher(k)",
	"\tif err != nil {",
	"\t\treturn []byte{}, err",
	"\t}",
	"\tiv := make([]byte, aes.BlockSize)",
	"\t_, err = rand.Read(iv)",
	"\tif err != nil {",
	"\t\treturn []byte{}, err",
	"\t}",
	"\tmode := cipher.NewCBCEncrypter(block, iv)",
	"\tciphertext := make([]byte, len(plaintext))",
	"\tmode.CryptBlocks(ciphertext, plaintext)",
	"\treturn append(iv, ciphertext...), nil",
	"}",
	"",
	"func dec(k []byte, ciphertext []byte) ([]byte, error) {",
	"\tblock, err := aes.NewCipher(k)",
	"\tif err != nil {",
	"\t\treturn []byte{}, err",
	"\t}",
	"\tif len(ciphertext)%aes.BlockSize != 0 {",
	"\t\treturn []byte{}, fmt.Errorf(\"invalid ciphertext\")",
	"\t}",
	"\tif len(ciphertext) < aes.BlockSize {",
	"\t\treturn []byte{}, fmt.Errorf(\"invalid ciphertext\")",
	"\t}",
	"\tiv := ciphertext[:aes.BlockSize]",
	"\tmode := cipher.NewCBCDecrypter(block, iv)",
	"\tplaintext := make([]byte, len(ciphertext[aes.BlockSize:]))",
	"\tmode.CryptBlocks(plaintext, ciphertext)",
	"\treturn plaintext, nil",
	"}",
	"",
	"func aeadEnc(k []byte, plaintext []byte, ad []byte) ([]byte, error) {",
	"\tnonce := make([]byte, chacha20poly1305.NonceSizeX)",
	"\t_, err := rand.Read(nonce)",
	"\tif err != nil {",
	"\t\treturn []byte{}, err",
	"\t}",
	"\tenc, _ := chacha20poly1305.NewX(k)",
	"\tciphertext := enc.Seal(nil, nonce, plaintext, ad)",
	"\treturn append(nonce, ciphertext...), nil",
	"}",
	"",
	"func aeadDec(k []byte, ciphertext []byte, ad []byte) ([]byte, error) {",
	"\tenc, err := chacha20poly1305.NewX(k)",
	"\tif err != nil {",
	"\t\treturn []byte{}, err",
	"\t}",
	"\tnonce := ciphertext[:chacha20poly1305.NonceSizeX]",
	"\tif len(ciphertext) <= chacha20poly1305.NonceSizeX {",
	"\t\treturn []byte{}, fmt.Errorf(\"authenticated decryption failed\")",
	"\t}",
	"\tplaintext, err := enc.Open(",
	"\t\tnil, nonce,",
	"\t\tciphertext[chacha20poly1305.NonceSizeX:], ad,",
	"\t)",
	"\treturn plaintext, err",
	"}",
	"",
	"func pkeEnc(pk []byte, plaintext []byte) ([]byte, error) {",
	"\tesk, epk, err := ed25519Gen()",
	"\tif err != nil {",
	"\t\treturn []byte{}, err",
	"\t}",
	"\tss, err := x25519DhFromEd25519PublicKey(esk, pk)",
	"\tif err != nil {",
	"\t\treturn []byte{}, err",
	"\t}",
	"\tciphertext, err := enc(hash(ss), plaintext)",
	"\treturn append(epk, ciphertext...), err",
	"}",
	"",
	"func pkeDec(k []byte, ciphertext []byte) ([]byte, error) {",
	"\tif len(ciphertext) <= 32 {",
	"\t\treturn []byte{}, fmt.Errorf(\"invalid ciphertext\")",
	"\t}",
	"\tepk := ciphertext[:32]",
	"\tss, err := x25519DhFromEd25519PublicKey(k, epk)",
	"\tif err != nil {",
	"\t\treturn []byte{}, err",
	"\t}",
	"\tplaintext, err := dec(hash(ss), ciphertext)",
	"\treturn plaintext, err",
	"}",
	"",
	"func sign(k []byte, message []byte) []byte {",
	"\treturn ed25519.Sign(k, message)",
	"}",
	"",
	"func signverif(pk []byte, message []byte, signature []byte) bool {",
	"\treturn ed25519.Verify(pk, message, signature)",
	"}",
	"",
	"func ringsign(ka []byte, kb []byte, kc []byte, message []byte) []byte {",
	"\treturn []byte{}",
	"}",
	"",
	"func ringsignverif(",
	"\tpka []byte, pkb []byte, pkc []byte, message []byte, signature []byte,",
	") bool {",
	"\treturn false",
	"}",
	"",
	"func blind(k []byte, message []byte) []byte {",
	"\treturn []byte{}",
	"}",
	"",
	"func unblind(k []byte, message []byte, signature []byte) []byte {",
	"\treturn []byte{}",
	"}",
	"",
	"func shamirSplit(x []byte) []byte {",
	"\treturn []byte{}",
	"}",
	"",
	"func shamirJoin(a []byte, b []byte, c []byte) []byte {",
	"\treturn []byte{}",
	"}",
	"",
	"func generates() ([]byte, error) {",
	"\tb := make([]byte, 32)",
	"\t_, err := rand.Read(b)",
	"\tif err != nil {",
	"\t\treturn []byte{}, err",
	"\t}",
	"\treturn b, nil",
	"}",
	"",
	"/* ---------------------------------------------------------------- *",
	" * STATE MANAGEMENT                                                 *",
	" * ---------------------------------------------------------------- */",
	"",
	"/* ---------------------------------------------------------------- *",
	" * PROCESSES                                                        *",
	" * ---------------------------------------------------------------- */",
	""},
	"\n")
