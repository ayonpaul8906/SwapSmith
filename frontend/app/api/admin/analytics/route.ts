import { NextRequest, NextResponse } from 'next/server';
import { adminAuth } from '@/lib/firebase-admin';
import { getAdminByFirebaseUid } from '@/lib/admin-service';
import { getPlatformAnalytics } from '@/lib/admin-service';

export async function GET(req: NextRequest) {
  try {
    // Authenticate via Firebase ID token
    const authHeader = req.headers.get('authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    let decoded: { uid: string };
    try {
      decoded = await adminAuth.verifyIdToken(authHeader.substring(7));
    } catch {
      return NextResponse.json({ error: 'Invalid token' }, { status: 401 });
    }

    // Check admin role in DB
    const admin = await getAdminByFirebaseUid(decoded.uid);
    if (!admin) {
      return NextResponse.json({ error: 'Forbidden: Admin access required.' }, { status: 403 });
    }

    const analytics = await getPlatformAnalytics();
    return NextResponse.json({ success: true, data: analytics, admin: { name: admin.name, email: admin.email, role: admin.role } });
  } catch (err) {
    console.error('[Admin Analytics API]', err);
    return NextResponse.json({ error: 'Internal server error.' }, { status: 500 });
  }
}
