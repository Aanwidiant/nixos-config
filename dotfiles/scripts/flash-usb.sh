#!/usr/bin/env bash

set -e

# KONFIGURASI
ISO_PATH="$HOME/Downloads/linux.iso"
USB_DEVICE="/dev/sda"

echo "=============================="
echo "  USB FLASH TOOL (dd wrapper)"
echo "=============================="
echo ""

# Validasi file ISO
if [ ! -f "$ISO_PATH" ]; then
  echo "❌ File ISO tidak ditemukan:"
  echo "   $ISO_PATH"
  exit 1
fi

# Validasi device
if [ ! -b "$USB_DEVICE" ]; then
  echo "❌ Device tidak valid:"
  echo "   $USB_DEVICE"
  exit 1
fi

echo "⚠️  PERINGATAN:"
echo "Semua data di device ini akan TERHAPUS!"
echo ""

echo "📀 ISO File   : $ISO_PATH"
echo "💾 USB Device : $USB_DEVICE"
echo ""

# Tampilkan info disk
echo "🔍 Info device:"
lsblk "$USB_DEVICE"
echo ""

read -p "Ketik 'YES' untuk lanjut: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
  echo "❌ Dibatalkan"
  exit 0
fi

echo ""
echo "🚀 Mulai flashing..."

# Unmount semua partisi
echo "🔻 Unmounting..."
sudo umount ${USB_DEVICE}?* 2>/dev/null || true

# Proses dd
sudo dd if="$ISO_PATH" of="$USB_DEVICE" bs=4M status=progress oflag=sync

echo ""
echo "✅ Selesai!"
echo "Silakan cabut USB dengan aman."
