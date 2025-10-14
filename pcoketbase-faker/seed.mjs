import PocketBase from 'pocketbase';
import { faker } from '@faker-js/faker';
import 'dotenv/config';

const POCKETBASE_URL = 'http://127.0.0.1:8090';
const OWNER_EMAIL = process.env.PB_OWNER_EMAIL;
const OWNER_PASSWORD = process.env.PB_OWNER_PASSWORD;

// จำนวนข้อมูลที่ต้องการสร้าง
const NUM_MENU_ITEMS = 15;
const pb = new PocketBase(POCKETBASE_URL);

// --- 2. ฟังก์ชันสำหรับสร้างข้อมูลจำลอง ---
// ----------------------------------------
// สร้างข้อมูลตัวเลือกเสริม (Toppings/Customizations)
const generateCustomizations = (type) => {
  if (type === 'Drink') {
    return [
      { name: 'หวานน้อย', price: 0, category: 'Sweetness' },
      { name: 'หวานปกติ', price: 0, category: 'Sweetness' },
      { name: 'เพิ่มช็อตกาแฟ', price: 15.0, category: 'Addon' },
      { name: 'เพิ่มไข่มุก', price: 10.0, category: 'Addon' },
    ];
  }
  if (type === 'Food') {
    return [
      { name: 'ธรรมดา', price: 0, category: 'Size' },
      { name: 'พิเศษ', price: 10.0, category: 'Size' },
      { name: 'เพิ่มไข่ดาว', price: 10.0, category: 'Addon' },
      { name: 'ไม่ใส่ผัก', price: 0, category: 'Request' },
    ];
  }
  return [];
};

const generateMenuItem = () => {
  const type = faker.helpers.arrayElement(['Food', 'Drink']);
  const hasCustomizations = faker.datatype.boolean(0.7); 

  return {
    name: type === 'Food' ? faker.lorem.words({min: 1, max: 3}) : faker.lorem.words({min: 1, max: 3}),
    basePrice: faker.number.float({ min: 10, max: 150, multipleOf: 5 }),
    type: type,
    customizationOptions: hasCustomizations ? generateCustomizations(type) : [],
  };
};

// --- 3. ฟังก์ชันหลักในการทำงาน (Main Logic) ---
// --------------------------------------------
const clearCollection = async (collectionName) => {
  console.log(`🧹 Clearing collection: "${collectionName}"...`);
  const records = await pb.collection(collectionName).getFullList();
  for (const record of records) {
    await pb.collection(collectionName).delete(record.id);
  }
  console.log(`✅ Collection "${collectionName}" cleared.`);
};


// ฟังก์ชันหลัก
const main = async () => {
  try {
    console.log('--- Starting PocketBase Seeder ---');

    // 1. ล็อกอินด้วยบัญชีเจ้าของร้าน
    console.log('🔐 Authenticating as owner...');
    await pb.collection('users').authWithPassword(OWNER_EMAIL, OWNER_PASSWORD);
    console.log('✅ Authentication successful.');

    // 2. ล้างข้อมูลเก่า (แนะนำให้ทำทุกครั้งที่รัน)
    await clearCollection('menu');

    // 3. สร้างข้อมูลเมนู
    console.log(`🌱 Seeding ${NUM_MENU_ITEMS} menu items...`);
    const menuItemsData = Array.from({ length: NUM_MENU_ITEMS }, generateMenuItem);
    for (const item of menuItemsData) {
      await pb.collection('menu').create(item);
    }
    console.log('✅ Menu items seeded.');
    console.log('\n--- 🎉 Seeding complete! ---');

  } catch (error) {
    console.error('\n--- ❌ An error occurred ---');
    console.error(error.message);
    if (error.response) {
      console.error('Response data:', JSON.stringify(error.response, null, 2));
    }
  } finally {
     // 6. ล้างข้อมูลการล็อกอินออกจาก memory
    pb.authStore.clear();
  }
};

main();