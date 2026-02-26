import { NextRequest, NextResponse } from 'next/server';
import { adminAuth } from '@/lib/firebase-admin';
import { getAdminByFirebaseUid } from '@/lib/admin-service';

/**
 * POST /api/admin/verify
 * Verifies a Firebase ID token and returns admin info.
 * Used by the frontend to check admin status on page load.
 */
export async function POST(req: NextRequest) {
  try {
    const { idToken } = await req.json();
    if (!idToken) return NextResponse.json({ error: 'Missing token.' }, { status: 400 });

    let decoded: { uid: string };
    try {
      decoded = await adminAuth.verifyIdToken(idToken);
    } catch (tokenErr) {
      const msg = tokenErr instanceof Error ? tokenErr.message : String(tokenErr);
      console.error('[Admin Verify] verifyIdToken failed:', msg);
      // Distinguish config errors (500) from bad-token errors (401)
      if (msg.includes('not initialised') || msg.includes('not initialized')) {
        return NextResponse.json({ error: 'Server auth misconfiguration.' }, { status: 500 });
      }
      return NextResponse.json({ error: 'Invalid or expired token.' }, { status: 401 });
    }

    const admin = await getAdminByFirebaseUid(decoded.uid);
    if (!admin) {
      return NextResponse.json({ isAdmin: false }, { status: 200 });
    }

    return NextResponse.json({
      isAdmin: true,
      admin: { name: admin.name, email: admin.email, role: admin.role },
    });
  } catch (err) {
    console.error('[Admin Verify API]', err);
    return NextResponse.json({ error: 'Internal server error.' }, { status: 500 });
  }
}
