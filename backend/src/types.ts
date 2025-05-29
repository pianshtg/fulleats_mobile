export type Pekerjaan = {
    nama: string,
    lokasi: string
}

export type TenagaKerja = {
    tipe: string,
    peran: string,
    jumlah: number,
}

export type Dokumentasi = {
    url?: string,
    deskripsi: string
}

export type Aktivitas = {
    tipe: string,
    nama: string,
    dokumentasi: Dokumentasi[]
}

export type Cuaca = {
    tipe: string,
    waktu: string,
    waktu_mulai: string,
    waktu_berakhir: string,
}

export type laporanAktivitas = {
    mitra_nama: string,
    kontrak_nomor: string,
    kontrak_ss_pekerjaan_nama: string,
    laporan_tanggal: string,
    tipe_aktivitas_nama: string,
    aktivitas_nama: string,
    dokumentasi_arr: Dokumentasi[]
}

export type Log = {
    rekaman_id: string
    user_id: string
    nama_tabel: string
    perubahan: {}
    aksi: 'insert' | 'update' | 'delete'
}